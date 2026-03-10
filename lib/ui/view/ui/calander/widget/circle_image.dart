
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const CircularImage({
    Key? key,
    required this.imageUrl,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        imageUrl ?? '',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: Colors.blue[200],
            child: Icon(
              EneftyIcons.user_bold,
              size: size * 0.6,
              color: Colors.blue[700],
            ),
          );
        },
      ),
    );
  }
}