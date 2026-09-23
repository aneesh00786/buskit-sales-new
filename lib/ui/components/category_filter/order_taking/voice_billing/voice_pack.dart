/// One self-contained language definition for voice billing: recognition
/// locale, parsing vocabulary and every user-facing string. Swapping the active
/// pack is all that is needed to change language end-to-end.
class VoicePack {
  final String code;
  final String localeId;

  /// Number words -> value. Keys may be multi-word ("twenty five").
  final Map<String, int> numbers;
  final List<String> addWords;
  final List<String> removeWords;
  final List<String> discountWords;
  final List<String> undoWords;
  final List<String> percentWords;
  final List<String> andWords;

  /// Unit words: "5 pcs" / "2 packs". Also treated as filler in product text.
  final List<String> pcsWords;
  final List<String> packWords;

  /// Filler / unit words dropped from product text before catalog matching.
  final List<String> fillerWords;
  final List<String> yesWords;
  final List<String> noWords;
  final List<String> stopPhrases;

  /// Multi-word quantity phrases handled outside [numbers] ("half dozen").
  final Map<String, int> quantityPhrases;

  /// Templates use `{0}`, `{1}` placeholders.
  final Map<String, String> strings;

  const VoicePack({
    required this.code,
    required this.localeId,
    required this.numbers,
    required this.addWords,
    required this.removeWords,
    required this.discountWords,
    required this.undoWords,
    required this.percentWords,
    required this.andWords,
    required this.pcsWords,
    required this.packWords,
    required this.fillerWords,
    required this.yesWords,
    required this.noWords,
    required this.stopPhrases,
    required this.quantityPhrases,
    required this.strings,
  });

  /// Longest phrase (in tokens) across numbers and quantity phrases.
  int get maxNumberPhraseLength {
    var max = 1;
    for (final k in [...numbers.keys, ...quantityPhrases.keys]) {
      final n = k.split(' ').length;
      if (n > max) max = n;
    }
    return max;
  }

  String t(String key, [List<Object?> args = const []]) {
    var s = strings[key] ?? englishStrings[key] ?? key;
    for (var i = 0; i < args.length; i++) {
      s = s.replaceAll('{$i}', '${args[i]}');
    }
    return s;
  }

  static final VoicePack english = VoicePack(
    code: 'en',
    localeId: 'en_US',
    numbers: _buildEnglishNumbers(),
    addWords: [
      'add', 'put', 'insert', 'include', 'buy', 'order', 'get', 'need', 'give',
      'want',
    ],
    removeWords: ['return', 'remove', 'delete', 'reduce', 'minus'],
    discountWords: ['discount', 'offer'],
    undoWords: ['undo', 'revert'],
    percentWords: ['percent', 'percentage', 'per cent'],
    andWords: ['and', 'plus', 'also', 'then'],
    pcsWords: [
      'pcs', 'pc', 'piece', 'pieces', 'unit', 'units', 'bottle', 'bottles',
      'each',
    ],
    packWords: [
      'pack', 'packs', 'packet', 'packets', 'box', 'boxes', 'carton', 'cartons',
    ],
    fillerWords: [
      'box', 'boxes', 'unit', 'units', 'packet', 'packets', 'pack', 'packs',
      'piece', 'pieces', 'pcs', 'bottle', 'bottles', 'carton', 'cartons',
      'of', 'the', 'a', 'an', 'to', 'in', 'my', 'cart', 'bill', 'please',
      'kindly', 'some', 'damaged', 'for', 'me', 'i', 'um',
      'uh', 'hey', 'ok', 'okay', 'more', 'extra',
    ],
    yesWords: ['yes', 'yeah', 'yep', 'confirm', 'correct', 'sure', 'ok', 'okay'],
    noWords: ['no', 'nope', 'cancel', 'wrong', 'negative'],
    stopPhrases: [
      'stop', 'done', 'finish', 'finished', 'cancel session', 'end session',
      'stop listening',
    ],
    quantityPhrases: {'half dozen': 6, 'a couple': 2, 'couple': 2, 'dozen': 12},
    strings: englishStrings,
  );

  static const Map<String, String> englishStrings = {
    'holdToSpeak': 'Press and hold the mic while you speak',
    'listening': 'Listening…',
    'processing': 'Processing…',
    'micDenied': 'Microphone permission is required for voice billing',
    'speechUnavailable': 'Speech recognition is not available on this device',
    'busy': 'Finish or cancel the current command first',
    'noCustomer': 'Please select a customer first',
    'noSpeech': 'I did not hear anything. Please try again',
    'failEmpty': 'I did not hear anything. Please try again',
    'failOnlyFiller': 'I heard "{0}" but no product or quantity',
    'failVerbOnly': 'I heard "{0}" but not which product',
    'failQtyNoProduct': 'I heard the quantity {0} but no product name',
    'failDiscountNoValue': 'I heard a discount but not the percentage',
    'failNoCommand': 'I could not understand "{0}"',
    'unitPcs': 'pcs',
    'unitPack': 'pack',
    'unitLabel': 'Sell by',
    'unitDefaulted': 'No unit heard — using {0}',
    'confirmAdd': 'Add {0} {1}?',
    'confirmRemove': 'Return {0} {1}?',
    'confirmUndoAdd': 'Undo: remove {0} {1}?',
    'confirmUndoRemove': 'Undo: add back {0} {1}?',
    'assumedAdd': 'No action heard — assuming "add"',
    'confirm': 'Confirm',
    'cancel': 'Cancel',
    'dismiss': 'Dismiss',
    'yes': 'Yes',
    'no': 'No',
    'undo': 'Undo',
    'moreQueued': '+{0} more item(s) queued',
    'howMany': 'How many {0}?',
    'noMatch': 'No product found for "{0}"',
    'didYouMean': 'Did you mean…',
    'whichOne': 'Which one did you mean for "{0}"?',
    'speakOrTap': 'Tap an option, or press the mic and say it',
    'outOfStock': '{0} is out of stock',
    'onlyAvailable': 'Only {0} available for {1}. Add that instead?',
    'notInCart': '{0} is not in the cart',
    'onlyInCart': 'Only {0} of {1} in the cart. Return that instead?',
    'added': 'Added {0} {1}',
    'removed': 'Returned {0} {1}',
    'nothingToUndo': 'Nothing to undo',
    'discountUnsupported': 'Cart-level discounts ({0}%) cannot be applied by voice',
    'saveFailed': 'Could not update the cart: {0}',
    'speechError': 'Speech recognition error: {0}',
  };

  static const List<String> _ones = [
    'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
    'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
    'sixteen', 'seventeen', 'eighteen', 'nineteen',
  ];
  static const List<String> _tens = [
    '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty',
    'ninety',
  ];

  static Map<String, int> _buildEnglishNumbers() {
    final m = <String, int>{};
    for (var i = 0; i < 20; i++) {
      m[_ones[i]] = i;
    }
    for (var t = 2; t < 10; t++) {
      m[_tens[t]] = t * 10;
      for (var o = 1; o < 10; o++) {
        m['${_tens[t]} ${_ones[o]}'] = t * 10 + o;
      }
    }
    m['hundred'] = 100;
    m['one hundred'] = 100;
    return m;
  }
}

/// Translates a batch of strings into [targetLang]. Implemented by the host
/// (e.g. a Google Translate call).
typedef VoiceTranslate = Future<List<String>> Function(
    List<String> texts, String targetLang);

/// Builds a [VoicePack] for an arbitrary language by translating the English
/// vocabulary once. Persisting the result (keyed by tenant + language) is the
/// caller's job so the translation cost is paid once per tenant+language.
class VoicePackGenerator {
  final VoiceTranslate translate;
  const VoicePackGenerator(this.translate);

  static final RegExp _placeholder = RegExp(r'\{(\d+)\}');

  /// `{0}` -> `zqxargzerozqx`: plain alphanumerics survive machine translation.
  static String protect(String template) => template.replaceAllMapped(
      _placeholder, (m) => marker(int.parse(m.group(1)!)));

  static String marker(int i) => 'zqxarg${_digitWord(i)}zqx';

  static String _digitWord(int i) {
    const w = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven',
        'eight', 'nine'];
    return i.toString().split('').map((d) => w[int.parse(d)]).join('');
  }

  /// Restores markers to `{i}`. Returns null when any marker went missing.
  static String? restore(String translated, String original) {
    var out = translated;
    for (final m in _placeholder.allMatches(original)) {
      final i = int.parse(m.group(1)!);
      final re = RegExp(marker(i), caseSensitive: false);
      if (!re.hasMatch(out)) return null;
      out = out.replaceAll(re, '{$i}');
    }
    return out;
  }

  Future<VoicePack> generate(String langCode, String localeId) async {
    final en = VoicePack.english;
    // Numbers 0..99 are translated from their English words.
    final numberSources = <String>[
      for (var i = 0; i < 100; i++) _englishWordFor(i),
    ];
    final lists = <String, List<String>>{
      'add': en.addWords,
      'remove': en.removeWords,
      'discount': en.discountWords,
      'undo': en.undoWords,
      'percent': en.percentWords,
      'and': en.andWords,
      'pcs': en.pcsWords,
      'pack': en.packWords,
      'filler': en.fillerWords,
      'yes': en.yesWords,
      'no': en.noWords,
      'stop': en.stopPhrases,
    };
    final stringKeys = en.strings.keys.toList();

    final batch = <String>[
      ...numberSources,
      for (final l in lists.values) ...l,
      ...en.quantityPhrases.keys,
      for (final k in stringKeys) protect(en.strings[k]!),
    ];
    final out = await translate(batch, langCode);
    if (out.length != batch.length) {
      throw StateError('Translator returned ${out.length} of ${batch.length}');
    }
    var p = 0;
    String norm(String s) => s.toLowerCase().trim();

    final numbers = <String, int>{};
    for (var i = 0; i < 100; i++) {
      numbers[norm(out[p++])] = i;
    }
    final translatedLists = <String, List<String>>{};
    for (final e in lists.entries) {
      translatedLists[e.key] = [
        for (var i = 0; i < e.value.length; i++) norm(out[p++]),
      ];
    }
    final qtyPhrases = <String, int>{};
    for (final e in en.quantityPhrases.entries) {
      qtyPhrases[norm(out[p++])] = e.value;
    }
    final strings = <String, String>{};
    for (final k in stringKeys) {
      final original = en.strings[k]!;
      // A mangled placeholder falls back to English for just this string.
      strings[k] = restore(out[p++], original) ?? original;
    }
    return VoicePack(
      code: langCode,
      localeId: localeId,
      numbers: numbers,
      addWords: translatedLists['add']!,
      removeWords: translatedLists['remove']!,
      discountWords: translatedLists['discount']!,
      undoWords: translatedLists['undo']!,
      percentWords: translatedLists['percent']!,
      andWords: translatedLists['and']!,
      pcsWords: translatedLists['pcs']!,
      packWords: translatedLists['pack']!,
      fillerWords: translatedLists['filler']!,
      yesWords: translatedLists['yes']!,
      noWords: translatedLists['no']!,
      stopPhrases: translatedLists['stop']!,
      quantityPhrases: qtyPhrases,
      strings: strings,
    );
  }

  static String _englishWordFor(int n) {
    for (final e in VoicePack.english.numbers.entries) {
      if (e.value == n) return e.key;
    }
    return '$n';
  }
}
