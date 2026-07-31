import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'chatbot_controller.dart';

class ChatbotWidget extends StatelessWidget {
  const ChatbotWidget({Key? key}) : super(key: key);

  static void showChatbot(BuildContext context,
      {String routeName = '/dashboard'}) {
    final controller = Get.put(ChatbotController());
    controller.updatePageContext(routeName);

    final isTabletOrDesktop = MediaQuery.of(context).size.width >= 600;

    if (isTabletOrDesktop) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 560,
              height: MediaQuery.of(context).size.height * 0.82,
              child: const ChatbotWidget(),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: false,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          // Prevent negative height if keyboard is unusually large on very small screens
          final targetHeight = (MediaQuery.of(context).size.height * 0.85) - keyboardHeight;
          final safeHeight = targetHeight > 100 ? targetHeight : 100.0;
          
          return Padding(
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: safeHeight,
                child: const ChatbotWidget(),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChatbotController controller = Get.put(ChatbotController());

    return Container(
      width: double.infinity,
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, controller),

            // Message List / Sync Loader
            Expanded(
              child: Obx(() {
                if (controller.isSyncing.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: primaryColor),
                        const SizedBox(height: 12),
                        const Text(
                          "Downloading assistant data...",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        )
                      ],
                    ),
                  );
                }

                final messageList = controller.messages.toList();
                final isTyping = controller.isTyping.value;

                return ListView.builder(
                  controller: controller.scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: messageList.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messageList.length && isTyping) {
                      return _buildTypingIndicator();
                    }
                    final msg = messageList[index];
                    return _buildMessageItem(context, msg, controller);
                  },
                );
              }),
            ),

            // Input Bar
            _buildInputBar(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatbotController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5B63ED), Color(0xFF6B4EE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  "ThriveWoo Assistant",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Get instant answers about our B2B sales platform",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, ChatMessageModel msg,
      ChatbotController controller) {
    final isUser = msg.isUser;
    final formattedTime =
        "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: primaryColor,
                  child: Lottie.asset(
                    'assets/images/thrivewoo_bot.json',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(FontAwesomeIcons.robot,
                          size: 16, color: Colors.white);
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUser ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser 
                            ? const Color(0xFF6366F1).withOpacity(0.2)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                    border: isUser
                        ? null
                        : Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : primaryTextColor,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: isUser
                                  ? Colors.white70
                                  : Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                          if (!isUser) ...[
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: msg.text));
                                Get.snackbar(
                                  "Copied",
                                  "Message text copied to clipboard",
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: primaryColor,
                                  colorText: Colors.white,
                                );
                              },
                              child: const Icon(
                                Icons.copy_rounded,
                                size: 13,
                                color: primaryIconColor,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: lightPrimaryColor,
                  child: const Icon(Icons.person,
                      size: 16, color: primaryColor),
                ),
              ],
            ],
          ),

          // Quick replies / Popular question chips under bot messages
          if (!isUser &&
              msg.quickReplies != null &&
              msg.quickReplies!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        "🚀 Popular questions:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: msg.quickReplies!.map((reply) {
                      return InkWell(
                        onTap: () => controller.sendMessage(reply),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6B58F2),
                                Color(0xFF5A4AE3)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF6B58F2).withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            reply,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: primaryColor,
            child: Lottie.asset(
              'assets/images/thrivewoo_bot.json',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(FontAwesomeIcons.robot,
                    size: 16, color: Colors.white);
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Assistant is typing...",
                  style: TextStyle(
                    color: primaryIconColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, ChatbotController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.support_agent_rounded,
                  color: primaryColor),
              tooltip: "Contact Support",
              onPressed: () => controller.showSupportDialog(),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.textEditingController,
                  decoration: const InputDecoration(
                    hintText: "Ask me about ThriveWoo Sales...",
                    hintStyle: TextStyle(
                        fontSize: 13.5, color: Color(0xFF8C96A3)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onSubmitted: (text) => controller.sendMessage(text),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF6B58F2),
              child: IconButton(
                icon: const Icon(Icons.send_rounded,
                    size: 18, color: Colors.white),
                onPressed: () => controller
                    .sendMessage(controller.textEditingController.text),
              ),
            ),
          ],
        ),
      ),
    );
    }
}
