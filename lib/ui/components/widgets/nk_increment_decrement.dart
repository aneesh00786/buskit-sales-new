import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:flutter/material.dart';

class NkIncrementDecrement extends StatefulWidget {
  final int? initialCount;
  final bool isSmallSizeBtn;
  final Color? addBtnColor;
  final Color? removeBtnColor;
  final Function(int counts)? onValueChange;
  const NkIncrementDecrement({super.key, this.onValueChange, this.initialCount, this.isSmallSizeBtn = false, this.addBtnColor, this.removeBtnColor});

  @override
  State<NkIncrementDecrement> createState() => _NkIncrementDecrementState();
}

class _NkIncrementDecrementState extends State<NkIncrementDecrement> {
  int _count = 1;

  @override
  void initState() {
    _count = widget.initialCount ?? 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: [
      InkResponse(
        onTap: _onDecrement,
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: widget.removeBtnColor ?? errorColor,
            borderRadius: widget.isSmallSizeBtn ? null : BorderRadius.circular(4),
            shape: widget.isSmallSizeBtn ? BoxShape.circle : BoxShape.rectangle,
          ),
          child: const Center(
              child: FittedBox(
            child: Icon(
              Icons.remove,
              color: secondaryIconColor,
            ),
          )),
        ),
      ),
      nkSmallSizeBox(),
      MyRegularText(
        label: _count.toString(),
        fontSize: NkFontSize.largeFont(),
      ),
      nkSmallSizeBox(),
      InkResponse(
        onTap: _onIncrement,
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: widget.addBtnColor ?? switchColor,
            borderRadius: widget.isSmallSizeBtn ? null : BorderRadius.circular(4),
            shape: widget.isSmallSizeBtn ? BoxShape.circle : BoxShape.rectangle,
          ),
          child: const Center(
            child: FittedBox(
              child: Icon(
                Icons.add,
                color: secondaryIconColor,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  get _onIncrement => () {
        setState(() {
          _count = _count + 1;
          widget.onValueChange?.call(_count);
        });
      };

  get _onDecrement => () {
        if (_count != 0) {
          setState(() {
            _count = _count - 1;
            widget.onValueChange?.call(_count);
          });
        }
      };
}
