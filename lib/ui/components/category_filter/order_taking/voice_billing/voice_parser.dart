import 'voice_pack.dart';

enum VoiceAction { add, remove, discount, undo }

enum VoiceUnit { pcs, pack }

class ParsedCommand {
  final VoiceAction action;
  final int? quantity;
  final String productText;
  final double? percent;

  /// Spoken unit ("pcs" / "pack"); null when none was heard.
  final VoiceUnit? unit;

  /// True when no action verb was heard and "add" was inferred.
  final bool assumedAction;

  const ParsedCommand({
    required this.action,
    this.quantity,
    this.productText = '',
    this.percent,
    this.unit,
    this.assumedAction = false,
  });

  @override
  String toString() =>
      'ParsedCommand($action, qty: $quantity, "$productText", %: $percent, assumed: $assumedAction)';
}

enum ParseFailureKind {
  empty,
  onlyFiller,
  verbOnly,
  quantityWithoutProduct,
  discountWithoutValue,
  noCommand,
}

class ParseFailure {
  final ParseFailureKind kind;
  final String heard;
  final int? quantity;
  const ParseFailure(this.kind, this.heard, {this.quantity});

  String message(VoicePack pack) {
    switch (kind) {
      case ParseFailureKind.empty:
        return pack.t('failEmpty');
      case ParseFailureKind.onlyFiller:
        return pack.t('failOnlyFiller', [heard]);
      case ParseFailureKind.verbOnly:
        return pack.t('failVerbOnly', [heard]);
      case ParseFailureKind.quantityWithoutProduct:
        return pack.t('failQtyNoProduct', [quantity]);
      case ParseFailureKind.discountWithoutValue:
        return pack.t('failDiscountNoValue');
      case ParseFailureKind.noCommand:
        return pack.t('failNoCommand', [heard]);
    }
  }
}

class ParseResult {
  final List<ParsedCommand> commands;
  final ParseFailure? failure;
  const ParseResult.ok(this.commands) : failure = null;
  const ParseResult.fail(this.failure) : commands = const [];
  bool get isOk => failure == null;
}

class _NumSpan {
  final int start;
  final int end; // exclusive
  int value;
  final bool isDozen;
  _NumSpan(this.start, this.end, this.value, this.isDozen);
}

/// Bigram Dice coefficient in [0, 1].
double diceCoefficient(String a, String b) {
  if (a == b) return 1.0;
  if (a.length < 2 || b.length < 2) return 0.0;
  final counts = <String, int>{};
  for (var i = 0; i < a.length - 1; i++) {
    final g = a.substring(i, i + 2);
    counts[g] = (counts[g] ?? 0) + 1;
  }
  var overlap = 0;
  for (var i = 0; i < b.length - 1; i++) {
    final g = b.substring(i, i + 2);
    final c = counts[g] ?? 0;
    if (c > 0) {
      counts[g] = c - 1;
      overlap++;
    }
  }
  return 2.0 * overlap / ((a.length - 1) + (b.length - 1));
}

final RegExp _nonWord = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);

List<String> tokenizeVoice(String text) {
  final cleaned = text
      .toLowerCase()
      .replaceAll('%', ' percent ')
      .replaceAll(RegExp(r'[-_/]'), ' ')
      .replaceAll(_nonWord, ' ');
  return cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
}

class VoiceParser {
  final VoicePack pack;

  /// Minimum similarity for a misheard action verb ("ad" -> "add").
  final double actionThreshold;

  /// Catalog names whose words must not be read as numbers/filler/verbs
  /// ("7 Up", "Pack of Tea"). Only names that actually contain such words are
  /// kept.
  final List<List<String>> _protectedNames;

  /// "word number" / "number word" pairs found in catalog names, so a
  /// partial spoken name like "iphone 16" keeps its number.
  final Set<String> _numberPairs = {};

  VoiceParser(this.pack,
      {this.actionThreshold = 0.6, Iterable<String> catalogNames = const []})
      : _protectedNames = [] {
    final special = <String>{
      ...pack.fillerWords,
      ...pack.andWords,
      ...pack.pcsWords,
      ...pack.packWords,
      ...pack.numbers.keys.expand((k) => k.split(' ')),
      ...pack.quantityPhrases.keys.expand((k) => k.split(' ')),
    };
    final skipNeighbour = <String>{
      ...pack.fillerWords,
      ...pack.andWords,
      ...pack.pcsWords,
      ...pack.packWords,
    };
    bool isNum(String w) => int.tryParse(w) != null || pack.numbers.containsKey(w);
    for (final name in catalogNames) {
      final t = tokenizeVoice(name);
      if (t.isEmpty) continue;
      for (var i = 0; i + 1 < t.length; i++) {
        if ((isNum(t[i]) != isNum(t[i + 1])) &&
            !skipNeighbour.contains(t[i]) &&
            !skipNeighbour.contains(t[i + 1])) {
          _numberPairs.add('${t[i]} ${t[i + 1]}');
        }
      }
      if (t.any((w) => special.contains(w) || int.tryParse(w) != null ||
          _fuzzyActionStatic(w) != null)) {
        _protectedNames.add(t);
      }
    }
  }

  VoiceAction? _fuzzyActionStatic(String w) => _fuzzyAction(w);

  late final Set<String> _filler = pack.fillerWords.toSet();
  late final Set<String> _and = pack.andWords.toSet();

  /// Token indices covered by a protected catalog name in the current parse.
  Set<int> _prot = const {};

  late final Set<String> _pcs = pack.pcsWords.toSet();
  late final Set<String> _pack = pack.packWords.toSet();

  bool _isNoise(String t) =>
      _filler.contains(t) || _and.contains(t) || _pcs.contains(t) || _pack.contains(t);

  VoiceUnit? _unitOf(int i, List<String> tokens) {
    if (i < 0 || i >= tokens.length || _prot.contains(i)) return null;
    if (_pcs.contains(tokens[i])) return VoiceUnit.pcs;
    if (_pack.contains(tokens[i])) return VoiceUnit.pack;
    return null;
  }

  VoiceUnit? _findUnit(List<String> tokens, int from, int to) {
    for (var i = from; i < to; i++) {
      final u = _unitOf(i, tokens);
      if (u != null) return u;
    }
    return null;
  }

  Set<int> _findProtected(List<String> tokens) {
    final out = <int>{};
    for (final name in _protectedNames) {
      for (var i = 0; i + name.length <= tokens.length; i++) {
        var ok = true;
        for (var j = 0; j < name.length; j++) {
          if (tokens[i + j] != name[j]) {
            ok = false;
            break;
          }
        }
        if (ok) {
          for (var j = 0; j < name.length; j++) {
            out.add(i + j);
          }
        }
      }
    }
    // Partial names: "iphone 16" (from "iPhone 16 Pro") keeps its number.
    for (var i = 0; i + 1 < tokens.length; i++) {
      if (_numberPairs.contains('${tokens[i]} ${tokens[i + 1]}')) {
        out..add(i)..add(i + 1);
      }
    }
    return out;
  }

  /// True when the whole utterance is one of the stop phrases.
  bool isStopPhrase(String text) {
    final n = tokenizeVoice(text).join(' ');
    return pack.stopPhrases.any((p) => tokenizeVoice(p).join(' ') == n);
  }

  /// "yes" / "no" / null for a short spoken reply.
  bool? parseYesNo(String text) {
    final tokens = tokenizeVoice(text);
    if (tokens.isEmpty) return null;
    if (tokens.any(pack.noWords.contains)) return false;
    if (tokens.any(pack.yesWords.contains)) return true;
    return null;
  }

  VoiceAction? _fuzzyAction(String token) {
    if (token.length < 2) return null;
    final groups = <VoiceAction, List<String>>{
      VoiceAction.undo: pack.undoWords,
      VoiceAction.remove: pack.removeWords,
      VoiceAction.add: pack.addWords,
    };
    VoiceAction? best;
    var bestScore = 0.0;
    groups.forEach((action, words) {
      for (final w in words) {
        final s = diceCoefficient(token, w);
        if (s >= actionThreshold && s > bestScore) {
          best = action;
          bestScore = s;
        }
      }
    });
    return best;
  }

  List<_NumSpan> _scanNumbers(List<String> tokens) {
    final spans = <_NumSpan>[];
    final maxLen = pack.maxNumberPhraseLength;
    var i = 0;
    while (i < tokens.length) {
      _NumSpan? found;
      for (var len = maxLen; len >= 1 && found == null; len--) {
        if (i + len > tokens.length) continue;
        if (Iterable<int>.generate(len, (k) => i + k).any(_prot.contains)) continue;
        final phrase = tokens.sublist(i, i + len).join(' ');
        final q = pack.quantityPhrases[phrase];
        if (q != null) {
          found = _NumSpan(i, i + len, q, len == 1 && q == 12);
        } else if (pack.numbers.containsKey(phrase)) {
          found = _NumSpan(i, i + len, pack.numbers[phrase]!, false);
        } else if (len == 1) {
          final d = int.tryParse(phrase);
          if (d != null) found = _NumSpan(i, i + 1, d, false);
        }
      }
      if (found != null) {
        spans.add(found);
        i = found.end;
      } else {
        i++;
      }
    }
    // "2 dozen" -> 24
    final merged = <_NumSpan>[];
    for (final s in spans) {
      if (s.isDozen && merged.isNotEmpty) {
        final p = merged.last;
        if (p.end == s.start && !p.isDozen) {
          p.value *= 12;
          merged[merged.length - 1] =
              _NumSpan(p.start, s.end, p.value, false);
          continue;
        }
      }
      merged.add(s);
    }
    return merged;
  }

  String _clean(List<String> tokens, Set<int> skip, int from, int to) {
    final out = <String>[];
    for (var i = from; i < to; i++) {
      if (skip.contains(i)) continue;
      if (!_prot.contains(i) && _isNoise(tokens[i])) continue;
      out.add(tokens[i]);
    }
    return out.join(' ');
  }

  ParseResult parse(String text) {
    final heard = text.trim();
    final tokens = tokenizeVoice(text);
    if (tokens.isEmpty) return const ParseResult.fail(ParseFailure(ParseFailureKind.empty, ''));

    // Undo: first meaningful token resembles an undo word.
    _prot = _findProtected(tokens);
    final firstIdx = Iterable<int>.generate(tokens.length)
        .firstWhere((i) => _prot.contains(i) || !_isNoise(tokens[i]), orElse: () => -1);
    if (firstIdx == -1) {
      return ParseResult.fail(ParseFailure(ParseFailureKind.onlyFiller, heard));
    }
    if (!_prot.contains(firstIdx) &&
        _fuzzyAction(tokens[firstIdx]) == VoiceAction.undo) {
      return const ParseResult.ok([ParsedCommand(action: VoiceAction.undo)]);
    }

    final spans = _scanNumbers(tokens);
    final numberIdx = <int>{
      for (final s in spans) for (var i = s.start; i < s.end; i++) i,
    };

    // Discount: never split, even with two numbers.
    final hasDiscountWord = tokens.any((t) =>
        pack.discountWords.contains(t) || pack.percentWords.contains(t));
    if (hasDiscountWord) {
      if (spans.isEmpty) {
        return ParseResult.fail(
            ParseFailure(ParseFailureKind.discountWithoutValue, heard));
      }
      return ParseResult.ok([
        ParsedCommand(
            action: VoiceAction.discount, percent: spans.first.value.toDouble())
      ]);
    }

    // Action verb: the first meaningful token, if it is not itself a number.
    VoiceAction? action;
    final skip = <int>{};
    if (!numberIdx.contains(firstIdx) && !_prot.contains(firstIdx)) {
      final a = _fuzzyAction(tokens[firstIdx]);
      if (a != null && a != VoiceAction.undo) {
        action = a;
        skip.add(firstIdx);
      }
    }
    final assumed = action == null;

    final items = <({int? qty, String text, VoiceUnit? unit})>[];
    if (spans.length >= 2) {
      final preText = _clean(tokens, {...skip, ...numberIdx}, 0, spans.first.start);
      if (preText.isEmpty) {
        // "<qty> <product> and <qty> <product>"
        for (var i = 0; i < spans.length; i++) {
          final to = i + 1 < spans.length ? spans[i + 1].start : tokens.length;
          items.add((
            qty: spans[i].value,
            text: _clean(tokens, {...skip, ...numberIdx}, spans[i].end, to),
            unit: _findUnit(tokens, spans[i].end, to),
          ));
        }
      } else {
        // "<product> <qty> and <product> <qty>"
        var from = 0;
        for (var i = 0; i < spans.length; i++) {
          // A unit right after the number belongs to this item.
          final after = _unitOf(spans[i].end, tokens);
          items.add((
            qty: spans[i].value,
            text: _clean(tokens, {...skip, ...numberIdx}, from, spans[i].start),
            unit: after ?? _findUnit(tokens, from, spans[i].start),
          ));
          from = spans[i].end + (after != null ? 1 : 0);
        }
        final trailing = _clean(
            tokens, {...skip, ...numberIdx}, spans.last.end, tokens.length);
        if (trailing.isNotEmpty) {
          return ParseResult.fail(
              ParseFailure(ParseFailureKind.noCommand, heard));
        }
      }
    } else {
      items.add((
        qty: spans.isEmpty ? null : spans.first.value,
        text: _clean(tokens, {...skip, ...numberIdx}, 0, tokens.length),
        unit: (spans.isEmpty ? null : _unitOf(spans.first.end, tokens)) ??
            _findUnit(tokens, 0, tokens.length),
      ));
    }

    final commands = <ParsedCommand>[];
    for (final it in items) {
      if (it.text.isEmpty) {
        if (it.qty != null) {
          return ParseResult.fail(ParseFailure(
              ParseFailureKind.quantityWithoutProduct, heard,
              quantity: it.qty));
        }
        return ParseResult.fail(ParseFailure(
            action != null ? ParseFailureKind.verbOnly : ParseFailureKind.onlyFiller,
            heard));
      }
      commands.add(ParsedCommand(
        action: action ?? VoiceAction.add,
        quantity: it.qty,
        productText: it.text,
        unit: it.unit,
        assumedAction: assumed,
      ));
    }
    return ParseResult.ok(commands);
  }
}

// ── Catalog matching ────────────────────────────────────────────────────────

class ScoredMatch {
  final int index;
  final double score;
  const ScoredMatch(this.index, this.score);
}

enum MatchKind { matched, ambiguous, suggestions, none }

class MatchResult {
  final MatchKind kind;
  final List<ScoredMatch> options;
  const MatchResult(this.kind, this.options);
  ScoredMatch? get single => kind == MatchKind.matched ? options.first : null;
}

/// Consonant-skeleton key so that "bro", "bru" and "brew" collapse together.
String phoneticKey(String token) {
  var t = token.toLowerCase();
  if (t.length < 2) return t;
  t = t
      .replaceAll('ph', 'f')
      .replaceAll('ck', 'k')
      .replaceAll('kn', 'n')
      .replaceAll('wr', 'r')
      .replaceAll(RegExp(r'c(?=[eiy])'), 's')
      .replaceAll('c', 'k')
      .replaceAll('q', 'k')
      .replaceAll('x', 'ks')
      .replaceAll('z', 's');
  final buf = StringBuffer(t[0]);
  const skip = 'aeiouyhw';
  for (var i = 1; i < t.length; i++) {
    final ch = t[i];
    if (skip.contains(ch)) continue;
    if (buf.toString().endsWith(ch)) continue;
    buf.write(ch);
  }
  return buf.toString();
}

class ProductMatcher {
  /// Score at or above which a name counts as a match.
  final double matchThreshold;

  /// Score at or above which a name is offered as a "did you mean" suggestion.
  final double suggestThreshold;

  /// Scores within this distance of the best are considered tied.
  final double tieMargin;

  const ProductMatcher({
    this.matchThreshold = 0.8,
    this.suggestThreshold = 0.4,
    this.tieMargin = 0.001,
  });

  double score(String query, String name) {
    final q = tokenizeVoice(query);
    final n = tokenizeVoice(name);
    if (q.isEmpty || n.isEmpty) return 0;
    final qj = q.join('');
    final nj = n.join('');
    if (qj == nj) return 1.0;

    var best = diceCoefficient(qj, nj);

    // Sound-alike: same consonant skeleton counts as a near-exact match.
    final qp = q.map(phoneticKey).join('');
    final np = n.map(phoneticKey).join('');
    if (qp.length >= 3) {
      if (qp == np) {
        if (0.95 > best) best = 0.95;
      } else {
        final pd = diceCoefficient(qp, np);
        if (pd >= 0.85 && pd * 0.95 > best) best = pd * 0.95;
      }
    }

    final allFound = q.every((qt) => n.any((nt) =>
        nt == qt ||
        diceCoefficient(qt, nt) >= 0.8 ||
        (qt.length >= 3 && nt.length >= 3 && phoneticKey(qt) == phoneticKey(nt))));
    if (allFound) {
      final containment = 0.9 + 0.1 * (q.length / n.length).clamp(0.0, 1.0);
      if (containment > best) best = containment;
    }
    return best;
  }

  MatchResult match(String query, List<String> names, {int maxOptions = 5}) {
    final scored = <ScoredMatch>[
      for (var i = 0; i < names.length; i++) ScoredMatch(i, score(query, names[i])),
    ]..sort((a, b) => b.score.compareTo(a.score));

    if (scored.isEmpty || scored.first.score < suggestThreshold) {
      return const MatchResult(MatchKind.none, []);
    }
    final top = scored.first.score;
    if (top >= matchThreshold) {
      final tied =
          scored.where((s) => top - s.score <= tieMargin).take(maxOptions).toList();
      if (tied.length == 1) return MatchResult(MatchKind.matched, tied);
      return MatchResult(MatchKind.ambiguous, tied);
    }
    return MatchResult(
      MatchKind.suggestions,
      scored.where((s) => s.score >= suggestThreshold).take(maxOptions).toList(),
    );
  }
}
