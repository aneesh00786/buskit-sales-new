import 'package:flutter/material.dart';

Widget dialogCloseButton1(BuildContext context, Color color) {
  return CircleAvatar(
    backgroundColor: Colors.transparent,
    child: SizedBox(
      width: 20.8,
      height: 20.8,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.5),
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: color,
              size: 12,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Navigator.of(context).pop(); // Use the passed context here
            },
          ),
        ),
      ),
    ),
  );
}
Widget dialogCloseButton2(BuildContext context, Color color) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: SizedBox(
      width: 15.8,
      height: 15.8,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.9),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
                Icons.close,
                color: color,
                size: 10,
              ),
          ),
        ),
      ),
    ),
  );
}
