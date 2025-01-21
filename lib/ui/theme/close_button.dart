import 'package:flutter/material.dart';

Widget dialogCloseButton1(BuildContext context, Color color) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).pop();
    },
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 25.8,
        height: 25.8,
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
                size: 16,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
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
   width: 25.8,
        height: 25.8,
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
