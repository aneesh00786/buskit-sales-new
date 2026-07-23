import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chatbot_knowledge_base.dart';

class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? quickReplies;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.quickReplies,
  });
}

class ChatbotController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isTyping = false.obs;
  final RxList<String> suggestions = <String>[].obs;

  final RxBool isSyncing = false.obs;

  String currentRoute = '/dashboard';

  @override
  void onInit() {
    super.onInit();
    isSyncing.value = true;
    ChatbotKnowledgeBase.initAndSync().then((_) {
      isSyncing.value = false;
      resetChat();
    });
  }

  void updatePageContext(String routeName) {
    currentRoute = routeName;
    resetChatForCurrentPage();
  }

  void resetChatForCurrentPage() {
    resetChat();
  }

  void updateSuggestions() {
    final config = ChatbotKnowledgeBase.getConfigForRoute(currentRoute);
    suggestions.assignAll(config.suggestions);
    if (messages.isNotEmpty && !messages.first.isUser) {
      messages[0] = ChatMessageModel(
        id: messages.first.id,
        text: messages.first.text,
        isUser: false,
        timestamp: messages.first.timestamp,
        quickReplies: config.suggestions,
      );
    }
  }

  void resetChat() {
    // Check if knowledge base is loaded; if not, trigger a sync and wait
    if (ChatbotKnowledgeBase.chatPages.length <= 1) {
      isSyncing.value = true;
      ChatbotKnowledgeBase.initAndSync().then((_) {
        isSyncing.value = false;
        _rebuildWelcomeMessage();
      });
      return;
    }
    _rebuildWelcomeMessage();
  }

  void _rebuildWelcomeMessage() {
    final config = ChatbotKnowledgeBase.getConfigForRoute(currentRoute);
    messages.clear();
    messages.add(
      ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            "👋 Welcome to ThriveWoo!\n\nLooking for quick help with ThriveWoo Sales? Ask a question or select one below to get an immediate answer.",
        isUser: false,
        timestamp: DateTime.now(),
        quickReplies: config.suggestions,
      ),
    );
    suggestions.assignAll(config.suggestions);
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    messages.add(
      ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: trimmedText,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    textEditingController.clear();
    _scrollToBottom();

    isTyping.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    isTyping.value = false;

    final answer;
    final cleanText = trimmedText.toLowerCase();
    if (cleanText == 'hi' || cleanText == 'hello' || cleanText == 'hey') {
      answer = "Hello! How can I assist you today? Feel free to ask me any questions about the app's features.";
    } else {
      answer = ChatbotKnowledgeBase.findBestAnswer(
        trimmedText,
        currentRoute: currentRoute,
      );
    }

    messages.add(
      ChatMessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
        quickReplies: _getRelevantReplies(trimmedText),
      ),
    );

    _scrollToBottom();
  }

  List<String> _getRelevantReplies(String query) {
    final config = ChatbotKnowledgeBase.getConfigForRoute(currentRoute);
    final queryLower = query.toLowerCase();
    return config.suggestions
        .where((q) => !queryLower.contains(q.toLowerCase()))
        .take(4)
        .toList();
  }

  Future<void> submitSupportRequest(
      String name, String email, String issue) async {
    if (name.isEmpty || email.isEmpty || issue.isEmpty) return;

    isTyping.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    isTyping.value = false;

    messages.add(
      ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            "✅ Support request submitted successfully!\n\nTicket Reference: #TW-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}\nName: $name\nEmail: $email\n\nOur team will review your inquiry and contact you shortly.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textEditingController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
