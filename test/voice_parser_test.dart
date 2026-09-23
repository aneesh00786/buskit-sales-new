import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/voice_billing/voice_pack.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/voice_billing/voice_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = VoiceParser(VoicePack.english);

  test('simple add', () {
    final r = parser.parse('add 5 Coca-Cola');
    expect(r.commands.single.action, VoiceAction.add);
    expect(r.commands.single.quantity, 5);
    expect(r.commands.single.productText, 'coca cola');
    expect(r.commands.single.assumedAction, false);
  });

  test('misheard verb resolves', () {
    expect(parser.parse('ad 5 sprite').commands.single.action, VoiceAction.add);
  });

  test('implicit add is flagged', () {
    final c = parser.parse('5 boxes of sprite').commands.single;
    expect(c.action, VoiceAction.add);
    expect(c.assumedAction, true);
    expect(c.productText, 'sprite');
  });

  test('multi item both orderings', () {
    var r = parser.parse('add 2 Coca-Cola and 3 Sprite');
    expect(r.commands.map((c) => [c.quantity, c.productText]),
        [[2, 'coca cola'], [3, 'sprite']]);
    r = parser.parse('add coca cola 2 and sprite 3');
    expect(r.commands.map((c) => [c.quantity, c.productText]),
        [[2, 'coca cola'], [3, 'sprite']]);
  });

  test('spelled, multi-word, dozen', () {
    expect(parser.parse('add twenty five sprite').commands.single.quantity, 25);
    expect(parser.parse('add a dozen sprite').commands.single.quantity, 12);
    expect(parser.parse('add half dozen sprite').commands.single.quantity, 6);
    expect(parser.parse('add a couple of sprite').commands.single.quantity, 2);
    expect(parser.parse('add 2 dozen sprite').commands.single.quantity, 24);
  });

  test('return and discount', () {
    final c = parser.parse('return 2 damaged Milk').commands.single;
    expect([c.action, c.quantity, c.productText], [VoiceAction.remove, 2, 'milk']);
    final d = parser.parse('apply 10% discount').commands.single;
    expect([d.action, d.percent], [VoiceAction.discount, 10.0]);
    expect(parser.parse('apply 10 percent discount on 2 items').commands.length, 1);
  });

  test('no quantity keeps command for tap entry', () {
    final c = parser.parse('add sprite').commands.single;
    expect(c.quantity, null);
  });

  test('distinct failures', () {
    ParseFailureKind k(String s) => parser.parse(s).failure!.kind;
    expect(k('add 5'), ParseFailureKind.quantityWithoutProduct);
    expect(k('add'), ParseFailureKind.verbOnly);
    expect(k('please the'), ParseFailureKind.onlyFiller);
    expect(k('discount'), ParseFailureKind.discountWithoutValue);
    expect(k(''), ParseFailureKind.empty);
  });

  test('bare product name asks for quantity by tap', () {
    final c = parser.parse('bro instant coffee').commands.single;
    expect([c.action, c.quantity, c.productText, c.assumedAction],
        [VoiceAction.add, null, 'bro instant coffee', true]);
  });

  test('undo and stop', () {
    expect(parser.parse('undo').commands.single.action, VoiceAction.undo);
    expect(parser.isStopPhrase('Stop'), true);
  });

  test('matcher', () {
    const m = ProductMatcher();
    final names = ['Coca Cola 250ml', 'Coca Cola 500ml', 'Sprite', 'Milk'];
    expect(m.match('sprite', names).kind, MatchKind.matched);
    expect(m.match('coca cola', names).kind, MatchKind.ambiguous);
    expect(m.match('sprit', names).single!.index, 2);
    expect(m.match('zzzz', names).kind, MatchKind.none);
    expect(m.match('bro instant coffee', ['Bru Instant Coffee', 'Milk']).kind,
        MatchKind.matched);
  });

  test('placeholder protection', () {
    final p = VoicePackGenerator.protect('Add {0} {1}?');
    expect(p.contains('{'), false);
    expect(VoicePackGenerator.restore('x $p y', 'Add {0} {1}?'), 'x Add {0} {1}? y');
    expect(VoicePackGenerator.restore('missing', 'Add {0}?'), null);
  });

  test('multi-word numbers use longest match; generated pack works', () async {
    final gen = VoicePackGenerator((texts, lang) async => texts);
    final pack = await gen.generate('xx', 'xx_XX');
    expect(pack.numbers['twenty five'], 25);
    expect(pack.t('confirmAdd', [3, 'Tea']), 'Add 3 Tea?');
  });

  test('phonetic matching catches sound-alikes', () {
    const m = ProductMatcher();
    final names = ['Bru Instant Coffee', 'Nescafe Classic', 'Milk'];
    for (final q in ['bro instant coffee', 'brew instant coffee', 'bru instant kofi']) {
      final r = m.match(q, names);
      expect(r.kind, MatchKind.matched, reason: q);
      expect(r.options.first.index, 0, reason: q);
    }
    expect(phoneticKey('bro'), phoneticKey('brew'));
  });

  test('numbers and filler inside catalog names are protected', () {
    final p = VoiceParser(VoicePack.english,
        catalogNames: ['7 Up', '5 Star', 'Pack of Tea', 'Sprite']);
    var c = p.parse('add 2 7 up').commands.single;
    expect([c.quantity, c.productText], [2, '7 up']);
    c = p.parse('add 7 up').commands.single;
    expect([c.quantity, c.productText], [null, '7 up']);
    c = p.parse('add 3 pack of tea').commands.single;
    expect([c.quantity, c.productText], [3, 'pack of tea']);
    final multi = p.parse('add 2 5 star and 3 sprite').commands;
    expect(multi.map((x) => [x.quantity, x.productText]),
        [[2, '5 star'], [3, 'sprite']]);
    // Unprotected behaviour unchanged.
    expect(parser.parse('add 5 sprite').commands.single.quantity, 5);
  });

  test('pcs / pack units', () {
    ParsedCommand one(String t, [VoiceParser? p]) => (p ?? parser).parse(t).commands.single;
    var c = one('add 5 pcs sprite');
    expect([c.quantity, c.unit, c.productText], [5, VoiceUnit.pcs, 'sprite']);
    c = one('add 2 packs of coca cola');
    expect([c.quantity, c.unit, c.productText], [2, VoiceUnit.pack, 'coca cola']);
    c = one('add 10 pieces coca cola');
    expect([c.unit, c.productText], [VoiceUnit.pcs, 'coca cola']);
    c = one('add 3 boxes sprite');
    expect(c.unit, VoiceUnit.pack);
    c = one('add 5 sprite');
    expect(c.unit, null);
    c = one('return 2 pcs milk');
    expect([c.action, c.unit], [VoiceAction.remove, VoiceUnit.pcs]);
    // per-item units in a batch, both orderings
    var m = parser.parse('add 2 packs coca cola and 6 pcs sprite').commands;
    expect(m.map((x) => [x.quantity, x.unit, x.productText]),
        [[2, VoiceUnit.pack, 'coca cola'], [6, VoiceUnit.pcs, 'sprite']]);
    m = parser.parse('add coca cola 2 packs and sprite 6 pcs').commands;
    expect(m.map((x) => [x.quantity, x.unit, x.productText]),
        [[2, VoiceUnit.pack, 'coca cola'], [6, VoiceUnit.pcs, 'sprite']]);
    // product literally named "Pack of Tea" is protected
    final p = VoiceParser(VoicePack.english, catalogNames: ['Pack of Tea']);
    c = one('add 3 pack of tea', p);
    expect([c.quantity, c.unit, c.productText], [3, null, 'pack of tea']);
    c = one('add 3 packs pack of tea', p);
    expect([c.unit, c.productText], [VoiceUnit.pack, 'pack of tea']);
  });

  test('partial catalog name keeps its number; quantity is then asked', () {
    final p = VoiceParser(VoicePack.english,
        catalogNames: ['iPhone 16 Pro 128GB', 'iPhone 15', 'Sprite']);
    var c = p.parse('iphone 16').commands.single;
    expect([c.quantity, c.productText], [null, 'iphone 16']);
    c = p.parse('add iphone 16').commands.single;
    expect([c.quantity, c.productText], [null, 'iphone 16']);
    c = p.parse('add 3 iphone 16').commands.single;
    expect([c.quantity, c.productText], [3, 'iphone 16']);
    // Unit words next to a number are not protected as name pairs.
    expect(p.parse('add 5 pcs sprite').commands.single.quantity, 5);
  });
}
