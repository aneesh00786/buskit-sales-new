import 'package:flutter/material.dart';

Widget dialogCloseButton1(BuildContext context, Color color) {
  return CircleAvatar(
    backgroundColor: Colors.transparent,
    child: SizedBox(
      width: 25.8,
      height: 25.8,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color, // Use the passed color here
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.5),
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: color, // Use the passed color here
              size: 16,
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
