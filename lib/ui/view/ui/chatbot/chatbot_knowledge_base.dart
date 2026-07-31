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

  static List<Set<String>> criticalGroups = [
    {'customer', 'customers', 'client', 'clients'},
    {'order', 'orders', 'booking', 'bookings'},
    {'lead', 'leads', 'prospect', 'prospects', 'inquiry', 'inquiries'},
    {'product', 'products', 'item', 'items', 'catalog', 'catalogue'},
    {'performance', 'sales', 'stats', 'statistics', 'target', 'targets', 'achievement', 'achievements'},
    {'calendar', 'schedule', 'appointment', 'appointments', 'meeting', 'meetings', 'event', 'events'},
    {'support', 'help', 'ticket', 'inquiry', 'request', 'issue', 'issues'},
    {'settings', 'preference', 'preferences', 'profile', 'logout', 'language', 'languages', 'password', 'login'}
  ];

  // ── Public API ────────────────────────────────────────────────────────────

  static Future<void> initAndSync() async {
    await loadFromLocalCache();
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

    // 3. Normalised / partial match (exact matches first)
    final cleanQuery = _normalizeText(queryLower);
    for (var pageConfig in chatPages.values) {
      for (var entry in pageConfig.knowledgeBase.entries) {
        final cleanKey = _normalizeText(entry.key);
        if (cleanKey == cleanQuery) {
          return entry.value;
        }
      }
    }

    // Then check for containment, choosing the candidate with the closest length to prevent early returns
    String? bestContainmentAnswer;
    int minLengthDiff = 9999;
    for (var pageConfig in chatPages.values) {
      for (var entry in pageConfig.knowledgeBase.entries) {
        final cleanKey = _normalizeText(entry.key);
        if (cleanQuery.contains(cleanKey) || cleanKey.contains(cleanQuery)) {
          final diff = (cleanKey.length - cleanQuery.length).abs();
          if (diff < minLengthDiff) {
            minLengthDiff = diff;
            bestContainmentAnswer = entry.value;
          }
        }
      }
    }
    if (bestContainmentAnswer != null) return bestContainmentAnswer;

    // 4. Keyword score match with Critical Group Alignment & Fuzzy Matching
    String? bestMatchAnswer;
    int maxScore = 0;
    final queryWords =
        cleanQuery.split(' ').where((w) => w.length > 2).toList();

    // Find which critical groups are present in the user's query with fuzzy matching
    final activeQueryGroups = <Set<String>>[];
    for (var group in criticalGroups) {
      if (queryWords.any((qWord) => group.any((gWord) => _areWordsSimilar(gWord, qWord)))) {
        activeQueryGroups.add(group);
      }
    }

    for (var pageConfig in chatPages.values) {
      for (var entry in pageConfig.knowledgeBase.entries) {
        final cleanKey = _normalizeText(entry.key);
        final keyWords =
            cleanKey.split(' ').where((w) => w.length > 2).toList();

        // Critical alignment check (fuzzy matched):
        bool aligned = true;
        for (var group in activeQueryGroups) {
          final hasGroupWordInKey = keyWords.any((kWord) => group.any((gWord) => _areWordsSimilar(gWord, kWord)));
          if (!hasGroupWordInKey) {
            aligned = false;
            break;
          }
        }
        if (!aligned) continue;

        int score = 0;
        for (var qWord in queryWords) {
          bool directMatch = keyWords.any((kWord) => _areWordsSimilar(kWord, qWord));
          if (directMatch) {
            score += 2;
          } else {
            bool foundSynonym = false;
            for (var group in criticalGroups) {
              if (group.any((gWord) => _areWordsSimilar(gWord, qWord))) {
                if (keyWords.any((kWord) => group.any((gWord) => _areWordsSimilar(gWord, kWord)))) {
                  score += 2;
                  foundSynonym = true;
                  break;
                }
              }
            }
            if (!foundSynonym) {
              bool partialMatch = false;
              for (var kWord in keyWords) {
                if (kWord.contains(qWord) || qWord.contains(kWord)) {
                   partialMatch = true;
                   break;
                }
              }
              if (partialMatch || cleanKey.contains(qWord)) {
                score += 1;
              }
            }
          }
        }

        if (score > maxScore) {
          maxScore = score;
          bestMatchAnswer = entry.value;
        }
      }
    }

    if (bestMatchAnswer != null && maxScore >= 4) return bestMatchAnswer;

    return "__NO_MATCH__";
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

      if (decoded['criticalGroups'] is List) {
        final List<Set<String>> parsedGroups = [];
        for (var group in (decoded['criticalGroups'] as List)) {
          if (group is List) {
            parsedGroups.add(group.map((e) => e.toString()).toSet());
          }
        }
        if (parsedGroups.isNotEmpty) {
          criticalGroups = parsedGroups;
        }
      }

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
        .replaceAll(RegExp(r"[?!.,:\-']"), '')
        .replaceAll(
            RegExp(
                r'\b(the|a|an|is|are|can|does|do|how|what|why|i|to|in|of|for|on)\b'),
            '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = _min3(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[t.length];
  }

  static int _min3(int a, int b, int c) {
    int m = a < b ? a : b;
    return m < c ? m : c;
  }

  static bool _areWordsSimilar(String w1, String w2) {
    if (w1 == w2) return true;
    if (w1.length > 3 && w2.length > 3) {
      if (w1.contains(w2) || w2.contains(w1)) return true;
    }
    final maxLen = w1.length > w2.length ? w1.length : w2.length;
    if (maxLen <= 2) return false;
    final allowedMistakes = maxLen <= 5 ? 1 : 2;
    final dist = _levenshteinDistance(w1, w2);
    return dist <= allowedMistakes;
  }

  static final Map<String, ChatbotPageConfig> _defaultChatPages = {};
}
