import 'package:flutter/material.dart';

class MyPopUpMenu<T> extends StatelessWidget {
  final List<PopupMenuItem<T>> items;
  final Widget buttonChild;
  final ValueChanged<T>? onItemSelected;
  final String? tooltip;
  final ShapeBorder? shape;
  final Offset offset;
  final Color? color;
  const MyPopUpMenu(
      {Key? key,
      required this.items,
      required this.buttonChild,
      this.onItemSelected,
      this.tooltip,
      this.shape,
      this.offset = Offset.zero,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: tooltip,
      shape: shape,
      offset: offset,
      color: color,
      position: PopupMenuPosition.under,
      child: buttonChild,
      onSelected: (value) {
        onItemSelected?.call(value as dynamic);
      },
      itemBuilder: (context) {
        return items ;
      },
    );
  }
}
