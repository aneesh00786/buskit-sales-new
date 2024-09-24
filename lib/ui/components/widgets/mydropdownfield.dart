import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@immutable
class MyDropdownField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String hint;
  final List<String> dropdownItems;
  final Widget? icon;
  final Widget? underLineIcon;
  final double? iconSize;
  final Color? iconEnabledColor;
  final Color? iconDisabledColor;
  final double? itemHeight;

  final FontWeight? fontWeight;
  final double? fontSize;
  final BorderRadius? borderRadius;
  final Color? fontColor;
  final AlignmentGeometry? alignment;
  final Color? dropdownColor;
  final bool? isEnable;

  const MyDropdownField({
    required this.hint,
    required this.dropdownItems,
    this.fontWeight,
    this.fontSize,
    this.iconSize,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.itemHeight,
    Key? key,
    this.borderRadius,
    this.fontColor,
    this.alignment,
    this.dropdownColor,
    this.onChanged,
    this.icon,
    this.underLineIcon,
    this.isEnable = true,
  }) : super(key: key);

  @override
  State<MyDropdownField> createState() => _MyDropdownFieldState();
}

class _MyDropdownFieldState extends State<MyDropdownField> {
  String? changedValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      borderRadius: widget.borderRadius,
      alignment: widget.alignment ?? AlignmentDirectional.center,
      value: changedValue ?? widget.dropdownItems[0],
      style: Get.theme.textTheme.displayMedium,
      //validator: validator,
      dropdownColor: widget.dropdownColor ?? secondaryColor,
      underline: widget.underLineIcon,
      /* selectedItemBuilder: (context) {
        return [
          const Icon(Icons.keyboard_arrow_down),
        ];
      },*/
      /* decoration: decoration ??
          DecorationUtils(context).getUnderlineInputDecoration(
            icon: icone,
            labelText: labelText,
            isRequire: isRequire,
            isEnable: isEnable,
            borderRadius: borderRadius ??
                BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
            fillColor: fillColor,
            alignLabelWithHint: alignLabelWithHint,
            disabledColor: disabledColor,
            enableColor: enableColor,
          ),*/
      isExpanded: true,
      hint: MyRegularText(label: widget.hint),
      items: widget.dropdownItems
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: MyRegularText(
                  label: item,
                  fontSize: widget.fontSize,
                  fontWeight: widget.fontWeight,
                  color: widget.fontColor,
                ),
              ))
          .toList(),
      onChanged: widget.isEnable!
          ? (value) {
              setState(() {
                changedValue = value as String;
                widget.onChanged?.call(value);
              });
            }
          : null,
      icon: widget.icon ??
          const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0XFF1C0F13),
          ),
      iconSize: widget.iconSize ?? 30,
      iconEnabledColor: widget.iconEnabledColor,
      iconDisabledColor: widget.iconDisabledColor,
      itemHeight: widget.itemHeight ?? 53,
    );
  }
}
