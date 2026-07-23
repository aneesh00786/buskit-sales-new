import 'package:flutter/material.dart';
import 'chatbot_top_bar_button.dart';

class ChatbotFabLauncher extends StatelessWidget {
  final String routeName;
  final double bottomMargin;
  final double rightMargin;

  const ChatbotFabLauncher({
    Key? key,
    this.routeName = '/dashboard',
    this.bottomMargin = 80.0,
    this.rightMargin = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottomMargin,
      right: rightMargin,
      child: ChatbotTopBarButton(routeName: routeName),
    );
  }
}
