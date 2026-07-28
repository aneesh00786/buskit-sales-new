import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'chatbot_widget.dart';

class ChatbotTopBarButton extends StatefulWidget {
  final String routeName;
  const ChatbotTopBarButton({Key? key, this.routeName = '/dashboard'})
      : super(key: key);

  @override
  State<ChatbotTopBarButton> createState() => _ChatbotTopBarButtonState();
}

class _ChatbotTopBarButtonState extends State<ChatbotTopBarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Tooltip(
        message: "ThriveWoo Sales AI Assistant",
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return InkWell(
              onTap: () => ChatbotWidget.showChatbot(context,
                  routeName: widget.routeName),
              borderRadius: BorderRadius.circular(20),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: _pulseAnimation.value,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset(
                        'assets/images/thrivewoo_bot.json',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            FontAwesomeIcons.robot,
                            color: Colors.white,
                            size: 18,
                          );
                        },
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8.5,
                          height: 8.5,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
