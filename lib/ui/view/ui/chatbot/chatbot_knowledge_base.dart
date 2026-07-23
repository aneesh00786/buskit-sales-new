import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';

class ChatbotPageConfig {
  final Map<String, String> knowledgeBase;
  final List<String> suggestions;

  ChatbotPageConfig({
    required this.knowledgeBase,
    required this.suggestions,
  });
}

class ChatbotKnowledgeBase {
  static const String hiveBoxName = 'chatbotSalesKnowledgeBox';
  static const String hiveCacheKey = 'json_data';

  static bool _hasSyncedInSession = false;
  static Map<String, ChatbotPageConfig> chatPages = _defaultChatPages;

  // ── Public API ────────────────────────────────────────────────────────────

  static Future<void> initAndSync() async {
    await loadFromLocalCache();
    // If we have no cached data, await the network sync immediately instead of calling it asynchronously.
    if (chatPages.isEmpty) {
      _hasSyncedInSession = true;
      await syncKnowledgeBaseFromServer();
    } else if (!_hasSyncedInSession) {
      _hasSyncedInSession = true;
      Future.microtask(() => syncKnowledgeBaseFromServer());
    }
  }

  static Future<void> loadFromLocalCache() async {
    try {
      final box = await _getHiveBox();
      final cachedJson = box.get(hiveCacheKey);
      if (cachedJson != null && cachedJson.toString().isNotEmpty) {
        _parseAndSetJson(cachedJson.toString());
      }
    } catch (e) {
      debugPrint("Error loading Sales Chatbot KnowledgeBase cache: $e");
    }
  }

  static Future<void> syncKnowledgeBaseFromServer() async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final url =
          "${ApiConstants.baseUrl}${ApiConstants.chatbotSalesKnowledgeBase}";
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        String jsonString;
        if (response.data is String) {
          jsonString = response.data;
        } else {
          jsonString = jsonEncode(response.data);
        }

        _parseAndSetJson(jsonString);

        final box = await _getHiveBox();
        await box.put(hiveCacheKey, jsonString);
        debugPrint(
            "Sales Chatbot KnowledgeBase successfully synced from server and cached.");
      }
    } catch (e) {
      debugPrint(
          "Sales Chatbot KnowledgeBase sync offline/failed (using local fallback): $e");
    }
  }

  // ── Lookup ─────────────────────────────────────────────────────────────────

  static ChatbotPageConfig getConfigForRoute(String route) {
    final normalized = route.toLowerCase();
    if (chatPages.containsKey(normalized)) return chatPages[normalized]!;
    for (var key in chatPages.keys) {
      if (normalized.contains(key.replaceAll('/', '')) && key != '/') {
        return chatPages[key]!;
      }
    }
    return chatPages['/dashboard'] ??
        ChatbotPageConfig(knowledgeBase: {}, suggestions: []);
  }

  /// Same algorithm as admin app — 4-pass matching with normalisation.
  static String findBestAnswer(String query, {String? currentRoute}) {
    final queryLower = query.toLowerCase().trim();
    if (queryLower.isEmpty) {
      return "Hello! How can I assist you with ThriveWoo Sales today?";
    }

    final config = getConfigForRoute(currentRoute ?? '/dashboard');

    // 1. Direct exact match in active-page knowledge base
    for (var entry in config.knowledgeBase.entries) {
      if (entry.key.toLowerCase().trim() == queryLower) return entry.value;
    }

    // 2. Exact match across all pages
    for (var pageConfig in chatPages.values) {
      for (var entry in pageConfig.knowledgeBase.entries) {
        if (entry.key.toLowerCase().trim() == queryLower) return entry.value;
      }
    }

    // 3. Normalised / partial match
    final cleanQuery = _normalizeText(queryLower);
    for (var pageConfig in chatPages.values) {
      for (var entry in pageConfig.knowledgeBase.entries) {
        final cleanKey = _normalizeText(entry.key);
        if (cleanKey == cleanQuery ||
            cleanQuery.contains(cleanKey) ||
            cleanKey.contains(cleanQuery)) {
          return entry.value;
        }
      }
    }

    // 4. Keyword score match
    String? bestMatchAnswer;
    int maxScore = 0;
    final queryWords =
        cleanQuery.split(' ').where((w) => w.length > 2).toList();

    for (var pageConfig in chatPages.values) {
      for (var entry in pageConfig.knowledgeBase.entries) {
        final cleanKey = _normalizeText(entry.key);
        final keyWords =
            cleanKey.split(' ').where((w) => w.length > 2).toList();

        int score = 0;
        for (var qWord in queryWords) {
          if (keyWords.contains(qWord)) {
            score += 2;
          } else if (cleanKey.contains(qWord)) {
            score += 1;
          }
        }

        if (score > maxScore) {
          maxScore = score;
          bestMatchAnswer = entry.value;
        }
      }
    }

    if (bestMatchAnswer != null && maxScore >= 2) return bestMatchAnswer;

    return "I'd be happy to help with ThriveWoo Sales! Could you clarify what you're looking for, or select one of the suggested questions below?";
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Future<Box> _getHiveBox() async {
    if (Hive.isBoxOpen(hiveBoxName)) return Hive.box(hiveBoxName);
    return await Hive.openBox(hiveBoxName);
  }

  static void _parseAndSetJson(String rawJson) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(rawJson);
      final Map<String, ChatbotPageConfig> parsedPages = {};

      decoded.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final kbMap = <String, String>{};
          final suggList = <String>[];

          if (value['knowledgeBase'] is Map) {
            (value['knowledgeBase'] as Map).forEach((k, v) {
              kbMap[k.toString()] = v.toString();
            });
          }

          if (value['suggestions'] is List) {
            for (var item in (value['suggestions'] as List)) {
              suggList.add(item.toString());
            }
          }

          parsedPages[key] =
              ChatbotPageConfig(knowledgeBase: kbMap, suggestions: suggList);
        }
      });

      if (parsedPages.isNotEmpty) chatPages = parsedPages;
    } catch (e) {
      debugPrint("Error parsing Sales Chatbot JSON: $e");
    }
  }

  static String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[?!.,:\-]'), '')
        .replaceAll(
            RegExp(
                r'\b(the|a|an|is|are|can|does|do|how|what|why|i|to|in|of|for|on)\b'),
            '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static final Map<String, ChatbotPageConfig> _defaultChatPages = {};
}
