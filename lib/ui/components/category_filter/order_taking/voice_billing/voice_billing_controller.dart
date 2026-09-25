import 'dart:async';
import 'dart:convert';

import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'voice_pack.dart';
import 'voice_parser.dart';

/// Resolves the voice pack for the app's current language (`Get.locale`).
/// English is built in; other languages come from [loader], which is expected
/// to fetch a cached pack (or generate one with [VoicePackGenerator] and cache
/// it per tenant + language). Unknown languages fall back to English.
class VoicePackRegistry {
  static Future<VoicePack?> Function(String langCode, String localeId)? loader;
  static final Map<String, VoicePack> _cache = {};

  static Future<VoicePack> forAppLocale() async {
    final locale = Get.locale ?? const Locale('en');
    final lang = locale.languageCode;
    if (lang == 'en') return VoicePack.english;
    final localeId = locale.countryCode == null || locale.countryCode!.isEmpty
        ? lang
        : '${lang}_${locale.countryCode}';
    final key = localeId;
    final cached = _cache[key];
    if (cached != null) return cached;
    try {
      final pack = await loader?.call(lang, localeId);
      if (pack != null) return _cache[key] = pack;
    } catch (_) {}
    return VoicePack.english;
  }
}

enum VoiceStage {
  idle,
  resolving,
  confirm,
  quantity,
  disambiguate,
  stockPrompt,
  error,
}

class VoiceCandidate {
  final ProductModel product;
  final Detail detail;
  final String name;
  final String key;
  const VoiceCandidate(this.product, this.detail, this.name, this.key);
}

class _UndoRecord {
  final VoiceAction action; // the action that was applied
  final VoiceCandidate candidate;
  final int quantity;
  final VoiceUnit unit;
  const _UndoRecord(this.action, this.candidate, this.quantity, this.unit);
}

class VoiceBillingController extends ChangeNotifier {
  final ProductsController productsController;

  /// Current customer id ('' when none selected).
  final String Function() customerId;

  /// Called after the cart changed so the host can refresh counts/toasts.
  final void Function(String customerId, String message) onApplied;

  VoiceBillingController({
    required this.productsController,
    required this.customerId,
    required this.onApplied,
  });

  static const Duration minListenDuration = Duration(milliseconds: 900);
  static const Duration tailGrace = Duration(milliseconds: 400);

  final SpeechToText _stt = SpeechToText();
  bool _sttReady = false;
  VoicePack _pack = VoicePack.english;
  late VoiceParser _parser = VoiceParser(_pack);
  final ProductMatcher _matcher = const ProductMatcher();

  // Session state (read live inside start/stop, never captured by widgets).
  bool _starting = false;
  bool _sessionActive = false;
  bool _stopping = false;
  bool _releasePending = false;
  DateTime? _listenStartedAt;
  String _lastWords = '';
  List<String> _lastAlternates = [];
  List<VoiceCandidate>? _candidateCache;
  Map<String, String>? _aliases; // spoken phrase -> candidate key
  static const _aliasPrefsKey = 'voice_billing_aliases';
  double _minLevel = -2;
  double _maxLevel = 10;

  // UI state
  String partialTranscript = '';
  double soundLevel = 0; // 0..1
  VoiceStage stage = VoiceStage.idle;
  String? message; // error / hint text
  ParsedCommand? current;
  VoiceCandidate? candidate;
  List<VoiceCandidate> options = [];
  int quantity = 1;
  VoiceUnit unit = VoiceUnit.pack;
  bool unitDefaulted = false; // no unit was spoken
  int stockAvailable = 0;
  final List<ParsedCommand> _queue = [];
  _UndoRecord? _undo;

  VoicePack get pack => _pack;
  bool get isListening => _sessionActive || _starting;
  int get queuedCount => _queue.length;
  bool get hasUndo => _undo != null;
  bool get hasUndoAdd => _undo?.action == VoiceAction.add;
  bool get quantityHeard => current?.quantity != null;
  bool get hasCard => stage != VoiceStage.idle;

  String unitName(VoiceUnit u) =>
      _pack.t(u == VoiceUnit.pcs ? 'unitPcs' : 'unitPack');

  /// "5 pcs" / "2 pack"
  String qtyLabel(int qty, [VoiceUnit? u]) => '$qty ${unitName(u ?? unit)}';

  void _notify() {
    if (hasListeners) notifyListeners();
  }

  // ── Microphone ────────────────────────────────────────────────────────────

  Future<bool> _ensureInit() async {
    if (_sttReady) return true;
    _sttReady = await _stt.initialize(
      onError: (e) {
        if (_sessionActive) {
          message = _pack.t('speechError', [e.errorMsg]);
          _notify();
        }
      },
      onStatus: (s) {
        // Real recognition start marks the beginning of the minimum window.
        if (s == 'listening' &&
            (_starting || _sessionActive) &&
            _listenStartedAt == null) {
          _listenStartedAt = DateTime.now();
        }
      },
    );
    return _sttReady;
  }

  /// Called on every pointer-down. Guards live here, not in the widget.
  Future<void> start() async {
    if (_starting || _sessionActive || _stopping) return;
    if (stage != VoiceStage.idle && stage != VoiceStage.disambiguate) {
      _flash(_pack.t('busy'));
      return;
    }
    if (stage == VoiceStage.idle && customerId().isEmpty) {
      _flash(_pack.t('noCustomer'));
      return;
    }
    if (stage == VoiceStage.idle) _candidateCache = null;
    _starting = true;
    _releasePending = false;
    _lastWords = '';
    _lastAlternates = [];
    partialTranscript = '';
    soundLevel = 0;
    _listenStartedAt = null;
    _notify();
    try {
      _pack = await VoicePackRegistry.forAppLocale();
      _parser = VoiceParser(_pack);
      final ok = await _ensureInit();
      if (!ok) {
        _flash(await _stt.hasPermission
            ? _pack.t('speechUnavailable')
            : _pack.t('micDenied'));
        return;
      }
      await _stt.listen(
        onResult: _onResult,
        localeId: _pack.localeId,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(minutes: 2),
        onSoundLevelChange: _onSound,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
        ),
      );
      _sessionActive = true;
      _listenStartedAt ??= DateTime.now();
    } catch (e) {
      _flash(_pack.t('speechError', ['$e']));
      return;
    } finally {
      _starting = false;
      _notify();
    }
    // Released while permission/init was still in flight: replay as a stop.
    if (_releasePending) {
      _releasePending = false;
      await stop();
    }
  }

  /// Called on every pointer-up / cancel.
  Future<void> stop() async {
    if (_starting) {
      _releasePending = true;
      return;
    }
    if (!_sessionActive || _stopping) return;
    _stopping = true;
    _sessionActive = false;
    try {
      final started = _listenStartedAt ?? DateTime.now();
      final elapsed = DateTime.now().difference(started);
      if (elapsed < minListenDuration) {
        await _stt.cancel();
        _resetLive();
        _flash(_pack.t('holdToSpeak'));
        return;
      }
      await _stt.stop();
      // stop() can resolve before the last transcript update lands.
      await Future.delayed(tailGrace);
      final words = _lastWords.trim();
      final alternates = List<String>.of(_lastAlternates);
      _resetLive();
      if (words.isEmpty) {
        _flash(_pack.t('noSpeech'));
        return;
      }
      await _handleTranscript(words, alternates);
    } finally {
      _stopping = false;
      _notify();
    }
  }

  void _onResult(SpeechRecognitionResult r) {
    // Keep accepting results during the post-stop grace window (_stopping).
    if (!(_starting || _sessionActive || _stopping)) return;
    _lastWords = r.recognizedWords;
    _lastAlternates = [
      r.recognizedWords,
      for (final a in r.alternates)
        if (a.recognizedWords.isNotEmpty &&
            a.recognizedWords != r.recognizedWords)
          a.recognizedWords,
    ];
    partialTranscript = r.recognizedWords;
    if (_sessionActive && _parser.isStopPhrase(r.recognizedWords)) {
      _discardSession();
      return;
    }
    _notify();
  }

  void _onSound(double level) {
    // Engines report different dB ranges; track the observed range.
    if (level < _minLevel) _minLevel = level;
    if (level > _maxLevel) _maxLevel = level;
    final min = _minLevel;
    final max = _maxLevel;
    if (max - min < 1) return;
    soundLevel = ((level - min) / (max - min)).clamp(0.0, 1.0);
    _notify();
  }

  Future<void> _discardSession() async {
    _sessionActive = false;
    _lastWords = '';
    _resetLive();
    await _stt.cancel();
    _notify();
  }

  void _resetLive() {
    partialTranscript = '';
    soundLevel = 0;
  }

  void _flash(String text) {
    message = text;
    if (stage == VoiceStage.idle) {
      current = null;
      stage = VoiceStage.error;
    }
    _notify();
  }

  // ── Transcript handling ───────────────────────────────────────────────────

  Future<void> _handleTranscript(String words,
      [List<String> alternates = const []]) async {
    if (_parser.isStopPhrase(words)) return;

    if (stage == VoiceStage.disambiguate) {
      final yn = _parser.parseYesNo(words);
      if (yn == false) {
        cancelCurrent();
        return;
      }
      final r = _matcher.match(words, [for (final o in options) o.name]);
      if (r.kind == MatchKind.matched) {
        await chooseOption(r.options.first.index);
      } else {
        message = _pack.t('speakOrTap');
        _notify();
      }
      return;
    }

    final all = await _loadCandidates();
    await _ensureAliases();
    _parser = VoiceParser(_pack, catalogNames: [for (final c in all) c.name]);
    final result =
        _pickBest([words, ...alternates.where((a) => a != words).take(4)], all);
    if (!result.isOk) {
      message = result.failure!.message(_pack);
      current = null;
      options = [];
      stage = VoiceStage.error;
      _notify();
      return;
    }
    _queue
      ..clear()
      ..addAll(result.commands);
    await _advance();
  }

  /// Parses every recognizer alternative and keeps the one whose product
  /// text matches the catalog best (a misheard top guess often has a better
  /// runner-up).
  ParseResult _pickBest(List<String> transcripts, List<VoiceCandidate> all) {
    final names = [for (final c in all) c.name];
    ParseResult? best;
    var bestRank = -2.0;
    for (final t in transcripts) {
      final r = _parser.parse(t);
      double rank;
      if (!r.isOk) {
        rank = -1;
      } else {
        final cmd = r.commands.first;
        if (cmd.action == VoiceAction.undo ||
            cmd.action == VoiceAction.discount) {
          rank = 3.5;
        } else if (_aliasFor(cmd.productText, all) != null) {
          rank = 4;
        } else {
          final m = _matcher.match(cmd.productText, names);
          final top = m.options.isEmpty ? 0.0 : m.options.first.score;
          rank = switch (m.kind) {
            MatchKind.matched => 3 + top,
            MatchKind.ambiguous => 2 + top,
            MatchKind.suggestions => 1 + top,
            MatchKind.none => 0,
          };
        }
      }
      if (rank > bestRank) {
        best = r;
        bestRank = rank;
      }
    }
    return best!;
  }

  // ── Learned aliases ───────────────────────────────────────────────────────

  String _norm(String s) => tokenizeVoice(s).join(' ');

  Future<void> _ensureAliases() async {
    if (_aliases != null) return;
    _aliases = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_aliasPrefsKey);
      if (raw != null) {
        (jsonDecode(raw) as Map<String, dynamic>)
            .forEach((k, v) => _aliases![k] = '$v');
      }
    } catch (_) {}
  }

  VoiceCandidate? _aliasFor(String phrase, List<VoiceCandidate> all) {
    final key = _aliases?[_norm(phrase)];
    if (key == null) return null;
    for (final c in all) {
      if (c.key == key) return c;
    }
    return null;
  }

  /// Remembers that this spoken phrase means this product (set when the user
  /// taps a suggestion or disambiguation option).
  Future<void> _learn(String phrase, VoiceCandidate c) async {
    final n = _norm(phrase);
    if (n.isEmpty) return;
    await _ensureAliases();
    _aliases![n] = c.key;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_aliasPrefsKey, jsonEncode(_aliases));
    } catch (_) {}
  }

  Future<void> _advance() async {
    message = null;
    options = [];
    candidate = null;
    if (_queue.isEmpty) {
      current = null;
      _candidateCache = null;
      stage = VoiceStage.idle;
      _notify();
      return;
    }
    current = _queue.removeAt(0);
    stage = VoiceStage.resolving;
    _notify();
    await _resolveCurrent();
  }

  Future<void> _resolveCurrent() async {
    final cmd = current!;
    if (cmd.action == VoiceAction.undo) {
      final u = _undo;
      if (u == null) return _fail(_pack.t('nothingToUndo'));
      candidate = u.candidate;
      quantity = u.quantity;
      unit = u.unit;
      unitDefaulted = false;
      stage = VoiceStage.confirm;
      return _notify();
    }
    if (cmd.action == VoiceAction.discount) {
      return _fail(_pack.t('discountUnsupported', [cmd.percent?.round()]));
    }

    final all = await _loadCandidates();
    await _ensureAliases();
    final learned = _aliasFor(cmd.productText, all);
    if (learned != null) {
      candidate = learned;
      _afterCandidate();
      return;
    }
    final r = _matcher.match(cmd.productText, [for (final c in all) c.name]);
    switch (r.kind) {
      case MatchKind.matched:
        candidate = all[r.options.first.index];
        _afterCandidate();
        break;
      case MatchKind.ambiguous:
        options = [for (final o in r.options) all[o.index]];
        message = _pack.t('whichOne', [cmd.productText]);
        stage = VoiceStage.disambiguate;
        _notify();
        break;
      case MatchKind.suggestions:
        options = [for (final o in r.options) all[o.index]];
        _fail(_pack.t('noMatch', [cmd.productText]), keepOptions: true);
        break;
      case MatchKind.none:
        _fail(_pack.t('noMatch', [cmd.productText]));
        break;
    }
  }

  void _afterCandidate() {
    options = [];
    message = null;
    _pickUnit();
    // Unit, quantity and confirm all live on one card; default to 1 when no
    // quantity was heard.
    quantity = current?.quantity ?? 1;
    stage = VoiceStage.confirm;
    _notify();
  }

  /// Spoken unit wins; otherwise Pack is the default. For returns, prefer the
  /// unit that is actually in the cart.
  void _pickUnit() {
    final c = candidate;
    final spoken = current?.unit;
    unitDefaulted = spoken == null;
    unit = spoken ?? VoiceUnit.pack;
    if (spoken == null &&
        c != null &&
        current?.action == VoiceAction.remove &&
        _cartQty(c, VoiceUnit.pack) <= 0 &&
        _cartQty(c, VoiceUnit.pcs) > 0) {
      unit = VoiceUnit.pcs;
    }
  }

  /// Tap toggle on the card.
  void setUnit(VoiceUnit u) {
    unit = u;
    unitDefaulted = false;
    _notify();
  }

  int _piecesFor(Detail d, VoiceUnit u, int qty) => u == VoiceUnit.pack
      ? qty * ((d.pieces ?? 1).floor().clamp(1, 1 << 30))
      : qty;

  int _unitsFromPieces(Detail d, VoiceUnit u, int pieces) => u == VoiceUnit.pack
      ? pieces ~/ ((d.pieces ?? 1).floor().clamp(1, 1 << 30))
      : pieces;

  void _fail(String text, {bool keepOptions = false}) {
    message = text;
    if (!keepOptions) options = [];
    stage = VoiceStage.error;
    _notify();
  }

  // ── Taps from the card ────────────────────────────────────────────────────

  /// Picks a disambiguation / "did you mean" option.
  Future<void> chooseOption(int index) async {
    if (index < 0 || index >= options.length) return;
    candidate = options[index];
    final phrase = current?.productText ?? '';
    if (phrase.isNotEmpty) _learn(phrase, candidate!);
    _afterCandidate();
  }

  void setQuantity(int value) {
    quantity = value < 1 ? 1 : value;
    _notify();
  }

  void confirmQuantity() {
    if (stage != VoiceStage.quantity) return;
    stage = VoiceStage.confirm;
    _notify();
  }

  /// Undo button: same tap-confirmed path as the spoken "undo".
  Future<void> requestUndo() async {
    if (stage != VoiceStage.idle) return;
    _queue
      ..clear()
      ..add(const ParsedCommand(action: VoiceAction.undo));
    await _advance();
  }

  /// Cancels only the item on screen; the rest of the batch continues.
  Future<void> cancelCurrent() => _advance();

  Future<void> dismissError() => _advance();

  Future<void> confirm() async {
    final cmd = current;
    final c = candidate;
    if (cmd == null || c == null || stage != VoiceStage.confirm) return;
    final isUndo = cmd.action == VoiceAction.undo;
    final action = isUndo
        ? (_undo!.action == VoiceAction.add
            ? VoiceAction.remove
            : VoiceAction.add)
        : cmd.action;

    if (action == VoiceAction.add) {
      final stock = c.detail.stock;
      if (stock != null) {
        if (stock <= 0) return _fail(_pack.t('outOfStock', [c.name]));
        // Stock is tracked in pieces; a pack consumes `pieces` of them.
        if (_piecesFor(c.detail, unit, quantity) > stock) {
          stockAvailable = _unitsFromPieces(c.detail, unit, stock.floor());
          if (stockAvailable <= 0) {
            return _fail(
                _pack.t('outOfStock', ['${c.name} (${unitName(unit)})']));
          }
          message =
              _pack.t('onlyAvailable', [qtyLabel(stockAvailable), c.name]);
          stage = VoiceStage.stockPrompt;
          return _notify();
        }
      }
    } else {
      final inCart = _cartQty(c, unit);
      if (inCart <= 0) {
        return _fail(_pack.t('notInCart', ['${c.name} (${unitName(unit)})']));
      }
      if (quantity > inCart) {
        stockAvailable = inCart;
        message = _pack.t('onlyInCart', [qtyLabel(inCart), c.name]);
        stage = VoiceStage.stockPrompt;
        return _notify();
      }
    }
    await _apply(action, c, quantity, unit, isUndo: isUndo);
  }

  /// "Only N available, add that instead?" -> Yes.
  Future<void> acceptStockLimit() async {
    final cmd = current;
    final c = candidate;
    if (cmd == null || c == null || stage != VoiceStage.stockPrompt) return;
    final isUndo = cmd.action == VoiceAction.undo;
    final action = isUndo
        ? (_undo!.action == VoiceAction.add
            ? VoiceAction.remove
            : VoiceAction.add)
        : cmd.action;
    await _apply(action, c, stockAvailable, unit, isUndo: isUndo);
  }

  Future<void> _apply(
      VoiceAction action, VoiceCandidate c, int qty, VoiceUnit u,
      {required bool isUndo}) async {
    final cust = customerId();
    if (cust.isEmpty) return _fail(_pack.t('noCustomer'));
    try {
      if (action == VoiceAction.add) {
        await _addToCart(c, qty, u, cust);
      } else {
        await _removeFromCart(c, qty, u, cust);
      }
    } catch (e) {
      return _fail(_pack.t('saveFailed', ['$e']));
    }
    final applied = _pack.t(action == VoiceAction.add ? 'added' : 'removed',
        [qtyLabel(qty, u), c.name]);
    _undo = isUndo ? null : _UndoRecord(action, c, qty, u);
    onApplied(cust, applied);
    await _advance();
  }

  // ── Cart access ───────────────────────────────────────────────────────────

  Future<void> _addToCart(
      VoiceCandidate c, int qty, VoiceUnit u, String cust) async {
    final catTax = (c.product.catTax ?? 0).toDouble();
    // Same as the variant dialog's Pack/Pcs dropdown, but on a copy so the
    // shared catalog object is not mutated.
    final detail = Detail.fromJson(c.detail.toJson())
      ..saleBy = u == VoiceUnit.pack ? 'Pack' : 'Pcs';
    await CartDatabaseManager().addToCart(
      customerId: cust,
      localCount: qty,
      detail: detail,
      isPack: u == VoiceUnit.pack,
      productName: c.product.pName ?? c.product.productName ?? '',
      inclTax: c.product.inclTax ?? '',
      isChcked: true,
      catId: c.product.catId ?? 0,
      catTax: catTax,
    );
    productsController.isCartModified.value = true;
  }

  bool _sameLine(CartItem item, VoiceCandidate c, VoiceUnit u, String cust) {
    final d = item.detail;
    return item.customerId == cust &&
        d.variationName == c.detail.variationName &&
        d.sellPrice == c.detail.sellPrice &&
        (item.isPack == true) == (u == VoiceUnit.pack) &&
        item.isPromo != true &&
        (d.bulkId == null || d.bulkId!.isEmpty);
  }

  List<CartItem> _matchingItems(VoiceCandidate c, VoiceUnit u) {
    final cust = customerId();
    final db = CartDatabaseManager();
    return [
      ...db.draftBox.values.where((i) => _sameLine(i, c, u, cust)),
      ...db.cartBox.values.where((i) => _sameLine(i, c, u, cust)),
    ];
  }

  int _cartQty(VoiceCandidate c, VoiceUnit u) =>
      _matchingItems(c, u).fold<num>(0, (s, i) => s + i.detail.count).floor();

  Future<void> _removeFromCart(
      VoiceCandidate c, int qty, VoiceUnit u, String cust) async {
    final db = CartDatabaseManager();
    var remaining = qty;
    for (final item in _matchingItems(c, u)) {
      if (remaining <= 0) break;
      final have = item.detail.count.floor();
      if (have <= 0) continue;
      final take = remaining < have ? remaining : have;
      remaining -= take;
      if (take >= have) {
        await db.deleteCartItem(item);
      } else {
        final newCount = have - take;
        item.totalPrice = item.totalPrice / have * newCount;
        item.detail.count = newCount;
        await item.save();
      }
    }
    await db.getCartItems(cust);
    productsController.isCartModified.value = true;
  }

  Future<List<VoiceCandidate>> _loadCandidates() async {
    final cached = _candidateCache;
    if (cached != null) return cached;
    final products = <ProductModel>[...productsController.products];
    try {
      final box = Hive.isBoxOpen('scidProductGroups')
          ? Hive.box<ScidProductGroup>('scidProductGroups')
          : await Hive.openBox<ScidProductGroup>('scidProductGroups');
      for (final g in box.values) {
        products.addAll(g.products);
      }
    } catch (_) {}
    try {
      if (Hive.isBoxOpen('products')) {
        products.addAll(Hive.box<ProductModel>('products').values);
      }
    } catch (_) {}

    final seen = <String>{};
    final out = <VoiceCandidate>[];
    for (final p in products) {
      final pName =
          (p.pName?.isNotEmpty == true ? p.pName : p.productName) ?? '';
      if (pName.isEmpty) continue;
      for (final d in p.detail ?? const <Detail>[]) {
        final vName = d.variationName ?? '';
        final name = vName.isEmpty || vName.toLowerCase() == pName.toLowerCase()
            ? pName
            : '$pName $vName';
        final key =
            '${p.productId ?? p.id}|${d.variationId ?? vName}|${d.sellPrice}';
        if (!seen.add(key)) continue;
        out.add(VoiceCandidate(p, d, name, key));
      }
    }
    return _candidateCache = out;
  }

  @override
  void dispose() {
    _stt.cancel();
    super.dispose();
  }
}
