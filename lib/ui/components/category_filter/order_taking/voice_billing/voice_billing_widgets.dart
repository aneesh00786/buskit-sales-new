import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';

import 'voice_billing_controller.dart';
import 'voice_parser.dart';

/// Press-and-hold mic button plus the tap-to-confirm card it drives.
class VoiceBillingButton extends StatefulWidget {
  final ProductsController productsController;
  final String Function() customerId;
  final void Function(String customerId, String message) onApplied;

  const VoiceBillingButton({
    super.key,
    required this.productsController,
    required this.customerId,
    required this.onApplied,
  });

  @override
  State<VoiceBillingButton> createState() => _VoiceBillingButtonState();
}

class _VoiceBillingButtonState extends State<VoiceBillingButton> {
  late final VoiceBillingController _c;
  OverlayEntry? _overlay;

  @override
  void initState() {
    super.initState();
    _c = VoiceBillingController(
      productsController: widget.productsController,
      customerId: widget.customerId,
      onApplied: widget.onApplied,
    )..addListener(_syncOverlay);
  }

  bool get _showCard => _c.hasCard || _c.isListening;

  void _syncOverlay() {
    if (!mounted) return;
    if (_showCard && _overlay == null) {
      _overlay = OverlayEntry(builder: (_) => _buildCard());
      Overlay.of(context).insert(_overlay!);
    } else if (!_showCard && _overlay != null) {
      _overlay!.remove();
      _overlay = null;
    }
  }

  @override
  void dispose() {
    _c.removeListener(_syncOverlay);
    _overlay?.remove();
    _overlay = null;
    _c.dispose();
    super.dispose();
  }

  // Down/up/cancel always call start()/stop(); all guards live in the controller.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        final level = _c.soundLevel;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_c.hasUndo && _c.stage == VoiceStage.idle)
              IconButton(
                tooltip: _c.pack.t('undo'),
                icon: const Icon(Icons.undo, color: Colors.black54),
                onPressed: _c.requestUndo,
              ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _c.start(),
              onTapUp: (_) => _c.stop(),
              onTapCancel: () => _c.stop(),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 42 + 14 * level,
                      height: 42 + 14 * level,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _c.isListening
                            ? Colors.redAccent.withOpacity(0.25)
                            : Colors.transparent,
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _c.isListening ? Colors.redAccent : primaryColor,
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Card ──────────────────────────────────────────────────────────────────

  Widget _buildCard() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: ListenableBuilder(
              listenable: _c,
              builder: (context, _) => DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.black87),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(child: _cardBody()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardBody() {
    final p = _c.pack;
    if (_c.isListening && _c.stage != VoiceStage.disambiguate) {
      return _listening();
    }
    final children = <Widget>[];
    switch (_c.stage) {
      case VoiceStage.idle:
        return _listening();
      case VoiceStage.resolving:
        children.add(Text(p.t('processing')));
        break;
      case VoiceStage.confirm:
      case VoiceStage.quantity:
        final isUndo = _c.current?.action == VoiceAction.undo;
        children
          ..add(_title(isUndo || _c.quantityHeard
              ? _confirmText()
              : p.t('howMany', [_c.candidate?.name ?? ''])))
          ..addAll(_notes());
        if (!isUndo) children.add(_QuantityEditor(controller: _c));
        children.add(_buttons([
          _btn(p.t('cancel'), _c.cancelCurrent, outlined: true),
          _btn(p.t('confirm'), _c.confirm),
        ]));
        break;
      case VoiceStage.disambiguate:
        children
          ..add(_title(_c.message ?? ''))
          ..add(Text(p.t('speakOrTap'),
              style: const TextStyle(fontSize: 12, color: Colors.black54)));
        if (_c.isListening) children.add(_listening());
        children
          ..add(const SizedBox(height: 8))
          ..addAll(_optionChips())
          ..add(_buttons([_btn(p.t('cancel'), _c.cancelCurrent, outlined: true)]));
        break;
      case VoiceStage.stockPrompt:
        children
          ..add(_title(_c.message ?? ''))
          ..addAll(_notes())
          ..add(_buttons([
            _btn(p.t('no'), _c.cancelCurrent, outlined: true),
            _btn(p.t('yes'), _c.acceptStockLimit),
          ]));
        break;
      case VoiceStage.error:
        children.add(_title(_c.message ?? ''));
        if (_c.options.isNotEmpty) {
          children
            ..add(Text(p.t('didYouMean'),
                style: const TextStyle(fontSize: 12, color: Colors.black54)))
            ..add(const SizedBox(height: 8))
            ..addAll(_optionChips());
        }
        children.add(_buttons([_btn(p.t('dismiss'), _c.dismissError)]));
        break;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _listening() {
    final t = _c.partialTranscript;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _Waveform(level: _c.soundLevel),
          const SizedBox(width: 12),
          Text(_c.pack.t('listening'),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
        if (t.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(t, style: const TextStyle(fontSize: 15)),
        ],
      ],
    );
  }

  String _confirmText() {
    final p = _c.pack;
    final name = _c.candidate?.name ?? '';
    if (_c.current?.action == VoiceAction.undo) {
      return p.t(
          _c.hasUndoAdd ? 'confirmUndoAdd' : 'confirmUndoRemove',
          [_c.qtyLabel(_c.quantity), name]);
    }
    return p.t(_c.current?.action == VoiceAction.remove ? 'confirmRemove' : 'confirmAdd',
        [_c.qtyLabel(_c.quantity), name]);
  }

  List<Widget> _notes() {
    final p = _c.pack;
    return [
      if (_c.current?.action != VoiceAction.undo) _unitToggle(),
      if (_c.unitDefaulted && _c.current?.action != VoiceAction.undo)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(p.t('unitDefaulted', [_c.unitName(_c.unit)]),
              style: const TextStyle(fontSize: 12, color: Colors.orange)),
        ),
      if (_c.current?.assumedAction == true)
        Text(p.t('assumedAdd'),
            style: const TextStyle(fontSize: 12, color: Colors.orange)),
      if (_c.queuedCount > 0)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(p.t('moreQueued', [_c.queuedCount]),
              style: const TextStyle(fontSize: 12, color: primaryColor)),
        ),
      const SizedBox(height: 12),
    ];
  }

  Widget _unitToggle() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text('${_c.pack.t('unitLabel')}  ',
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          for (final u in const [VoiceUnit.pack, VoiceUnit.pcs])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Pill(
                label: _c.unitName(u),
                selected: _c.unit == u,
                onTap: () => _c.setUnit(u),
              ),
            ),
        ],
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      );

  List<Widget> _optionChips() => [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _c.options.length; i++)
              _Pill(
                label: _c.options[i].name,
                selected: false,
                onTap: () => _c.chooseOption(i),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ];

  Widget _buttons(List<Widget> items) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final b in items) Padding(padding: const EdgeInsets.only(left: 8), child: b),
        ],
      );

  Widget _btn(String label, VoidCallback onTap, {bool outlined = false}) =>
      outlined
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade400),
              ),
              child: Text(label))
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, foregroundColor: Colors.white),
              child: Text(label));
}

/// Quick-pick chips, +/- stepper and a text field, all bound to one value.
class _QuantityEditor extends StatefulWidget {
  final VoiceBillingController controller;
  const _QuantityEditor({required this.controller});

  @override
  State<_QuantityEditor> createState() => _QuantityEditorState();
}

class _QuantityEditorState extends State<_QuantityEditor> {
  late final TextEditingController _text =
      TextEditingController(text: '${widget.controller.quantity}');

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
  }

  void _sync() {
    final v = '${widget.controller.quantity}';
    final typed = int.tryParse(_text.text);
    // Don't fight the user while they type (e.g. an empty field).
    if (typed != widget.controller.quantity && _text.text != v) {
      _text.value = TextEditingValue(
          text: v, selection: TextSelection.collapsed(offset: v.length));
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final n in const [1, 2, 3, 5, 10])
            _Pill(
              label: '$n',
              selected: c.quantity == n,
              onTap: () => c.setQuantity(n),
            ),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              color: primaryColor,
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => c.setQuantity(c.quantity - 1)),
          SizedBox(
            width: 72,
            child: TextField(
              controller: _text,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: primaryColor, width: 1.5)),
              ),
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n > 0) c.setQuantity(n);
              },
            ),
          ),
          IconButton(
              color: primaryColor,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => c.setQuantity(c.quantity + 1)),
        ]),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Waveform extends StatelessWidget {
  final double level;
  const _Waveform({required this.level});

  @override
  Widget build(BuildContext context) {
    const weights = [0.5, 0.8, 1.0, 0.8, 0.5];
    return SizedBox(
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final w in weights)
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 4,
              height: 6 + 22 * level * w,
              decoration: BoxDecoration(
                  color: Colors.redAccent, borderRadius: BorderRadius.circular(2)),
            ),
        ],
      ),
    );
  }
}

/// Explicitly coloured pill: selected = solid primary with white text,
/// unselected = white with a border and dark text (independent of app theme).
class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Pill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? primaryColor : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? primaryColor : Colors.grey.shade400),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
