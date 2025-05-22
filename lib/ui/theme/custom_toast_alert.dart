// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CustomToastPopup extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;

  const CustomToastPopup(
      {super.key, required this.message, required this.color, required this.icon});

  @override
  // ignore: library_private_types_in_public_api
  _CustomToastState createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToastPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: widget.color, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: widget.color,
                  radius: 12.0,
                  child: Icon(
                    widget.icon,
                    size: 16.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showCustomToastDisplay(
    BuildContext context, String message, Color color, IconData icon) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).viewInsets.top + 0.0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              child: CustomToastPopup(
                message: message,
                color: color,
                icon: icon,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(overlayEntry);

  // Automatically remove the toast after 2 seconds
  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}
