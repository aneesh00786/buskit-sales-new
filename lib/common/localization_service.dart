import 'dart:convert';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// IMPORTANT: Remember to import your ApiConstants file here!
// import 'package:your_app_name/path/to/api_constants.dart';

class LocalizationService extends GetxService {
  static const String _languageKey = 'selected_language';
  
  // 1. Replaced the static hardcoded key with a nullable dynamic variable
  String? _googleApiKey; 
  
  late SharedPreferences _prefs;
  Locale activeLocale = const Locale('en');

  Future<LocalizationService> init() async {
    _prefs = await SharedPreferences.getInstance();
    String? savedLanguage = _prefs.getString(_languageKey);

    if (savedLanguage != null) {
      activeLocale = _getLocaleFromCode(savedLanguage);
    } else {
      // Explicitly set the default to English if nothing is saved
      activeLocale = const Locale('en'); 
    }
    
<<<<<<< HEAD
    // Pre-fetch the config in background without blocking app startup
    _fetchConfig(); 
=======
    // 2. Pre-fetch the config when the service initializes
    await _fetchConfig(); 
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
    return this;
  }

  void changeLocale(String langCode) {
    final locale = _getLocaleFromCode(langCode);
    Get.updateLocale(locale);
    activeLocale = locale;
    _prefs.setString(_languageKey, langCode);
  }

  Locale _getLocaleFromCode(String langCode) {
    if (langCode.contains('-')) {
      var parts = langCode.split('-');
      return Locale(parts[0], parts[1]);
    }
    return Locale(langCode);
  }

  // 3. Added the method to fetch the config from your backend
  Future<void> _fetchConfig() async {
    // Skip if we already successfully fetched it
    if (_googleApiKey != null && _googleApiKey!.isNotEmpty) return;

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.config}');
<<<<<<< HEAD
      final response = await http.get(url).timeout(const Duration(seconds: 4));
=======
      final response = await http.get(url);
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _googleApiKey = data['googleTranslateKey'];
      } else {
        print("Config API Error: Failed to load configuration. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Network error while fetching config: $e");
    }
  }

  /// Fetches translations from Google API in chunks and saves to offline database
  Future<void> fetchAndSaveTranslations(String targetLangCode) async {
    // 1. Skip if it's English, since English is our base
    if (targetLangCode == 'en') return;

    // 2. Ensure we have the API key before proceeding
    await _fetchConfig();
    
    if (_googleApiKey == null || _googleApiKey!.isEmpty) {
      print("Translation aborted: Google API Key is missing.");
      return;
    }

    // 3. Load the base English file
    String enJsonString = await rootBundle.loadString('assets/locales/en.json');
    Map<String, dynamic> enMap = json.decode(enJsonString);

    List<String> keys = enMap.keys.toList();
    List<String> valuesToTranslate = enMap.values.map((e) => e.toString()).toList();

    // 4. Set up the Chunking Logic (Google API limit protection)
    const int chunkSize = 100; 
    List<String> allTranslatedValues = [];

    // 5. Loop through the English words in chunks
    for (int i = 0; i < valuesToTranslate.length; i += chunkSize) {
      int end = (i + chunkSize < valuesToTranslate.length) ? i + chunkSize : valuesToTranslate.length;
      List<String> chunk = valuesToTranslate.sublist(i, end);

      final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$_googleApiKey');
      
      try {
        print('api called');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'q': chunk,
            'source': 'en',
            'target': targetLangCode, // e.g., 'zh-CN'
            'format': 'text'
          }),
        );
        print('resposne form the translation api:${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final translations = data['data']['translations'] as List;
          allTranslatedValues.addAll(translations.map((t) => t['translatedText'].toString()));
        } else {
          print("Translation API Error on chunk $i: ${response.body}");
          return; // Stop process so we don't save corrupted data
        }
      } catch (e) {
        print("Network error during translation (Likely offline): $e");
        return; // Fails gracefully if offline
      }
    }

    // 6. Stitch the translated list back together
    if (allTranslatedValues.length == keys.length) {
      Map<String, String> translatedMap = {};
      for (int i = 0; i < keys.length; i++) {
        translatedMap[keys[i]] = allTranslatedValues[i];
      }

      // 7. Save to Offline Database (SharedPreferences)
      String getxKey = targetLangCode.replaceAll('-', '_');
      await _prefs.setString('lang_$getxKey', json.encode(translatedMap));

      // 8. Update GetX dynamically so the UI refreshes instantly!
      Get.appendTranslations({
        getxKey: translatedMap
      });
      
      print("Successfully translated and cached ${keys.length} words for $targetLangCode!");
    }
  }

 

  Future<bool> canChangeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = "${DateTime.now().year}-${DateTime.now().month}";
    final savedMonth = prefs.getString('lang_change_month');
    int count = prefs.getInt('lang_change_count') ?? 0;

    
    if (savedMonth != currentMonth) {
      await prefs.setString('lang_change_month', currentMonth);
      await prefs.setInt('lang_change_count', 0);
      return true;
    }

    return count < 3; // Limit to 3 times
  }

  Future<int> getRemainingChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = "${DateTime.now().year}-${DateTime.now().month}";
    final savedMonth = prefs.getString('lang_change_month');
    
    if (savedMonth != currentMonth) return 3;
    
    int count = prefs.getInt('lang_change_count') ?? 0;
    return 3 - count;
  }

  Future<void> recordLanguageChange() async { 
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = "${DateTime.now().year}-${DateTime.now().month}";
    final savedMonth = prefs.getString('lang_change_month');
    int count = prefs.getInt('lang_change_count') ?? 0;

    if (savedMonth != currentMonth) {
      await prefs.setString('lang_change_month', currentMonth);
      count = 0;
    }

    await prefs.setInt('lang_change_count', count + 1);
  }
}

// class LocalizationService extends GetxService {
//   static const String _languageKey = 'selected_language';
  
//   String? _googleApiKey; 
  
//   late SharedPreferences _prefs;
//   Locale activeLocale = const Locale('en');

//   Future<LocalizationService> init() async {
//     _prefs = await SharedPreferences.getInstance();
//     String? savedLanguage = _prefs.getString(_languageKey);

//     if (savedLanguage != null) {
//       activeLocale = _getLocaleFromCode(savedLanguage);
//     } else {
//       activeLocale = const Locale('en'); 
//     }
    
//     await _fetchConfig(); 
//     return this;
//   }

//   void changeLocale(String langCode) {
//     final locale = _getLocaleFromCode(langCode);
//     Get.updateLocale(locale);
//     activeLocale = locale;
//     _prefs.setString(_languageKey, langCode);
//   }

//   Locale _getLocaleFromCode(String langCode) {
//     if (langCode.contains('-')) {
//       var parts = langCode.split('-');
//       return Locale(parts[0], parts[1]);
//     }
//     return Locale(langCode);
//   }

//   // UPDATED: Using ApiConstants to build the URL
//   Future<void> _fetchConfig() async {
//     if (_googleApiKey != null && _googleApiKey!.isNotEmpty) return;

//     try {
//       // Combines "https://test.thrivewoo.com/" + "config"
//       final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.config}');
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _googleApiKey = data['googleTranslateKey'];
//       } else {
//         print("Config API Error: Failed to load configuration. Status Code: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Network error while fetching config: $e");
//     }
//   }

//   Future<void> fetchAndSaveTranslations(String targetLangCode) async {
//     if (targetLangCode == 'en') return;

//     await _fetchConfig();
    
//     if (_googleApiKey == null || _googleApiKey!.isEmpty) {
//       print("Translation aborted: Google API Key is missing.");
//       return;
//     }

//     try {
//       String enJsonString = await rootBundle.loadString('assets/locales/en.json');
//       Map<String, dynamic> enMap = json.decode(enJsonString);

//       List<String> keys = enMap.keys.toList();
//       List<String> valuesToTranslate = enMap.values.map((e) => e.toString()).toList();

//       const int chunkSize = 100; 
//       List<String> allTranslatedValues = [];

//       for (int i = 0; i < valuesToTranslate.length; i += chunkSize) {
//         int end = (i + chunkSize < valuesToTranslate.length) ? i + chunkSize : valuesToTranslate.length;
//         List<String> chunk = valuesToTranslate.sublist(i, end);

//         final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$_googleApiKey');
        
//         final response = await http.post(
//           url,
//           headers: {'Content-Type': 'application/json'},
//           body: json.encode({
//             'q': chunk,
//             'source': 'en',
//             'target': targetLangCode,
//             'format': 'text'
//           }),
//         );

//         if (response.statusCode == 200) {
//           final data = json.decode(response.body);
//           final translations = data['data']['translations'] as List;
//           allTranslatedValues.addAll(translations.map((t) => t['translatedText'].toString()));
//         } else {
//           print("Translation API Error: ${response.body}");
//           return; 
//         }
//       }

//       if (allTranslatedValues.length == keys.length) {
//         Map<String, String> translatedMap = {};
//         for (int i = 0; i < keys.length; i++) {
//           translatedMap[keys[i]] = allTranslatedValues[i];
//         }

//         String getxKey = targetLangCode.replaceAll('-', '_');
//         await _prefs.setString('lang_$getxKey', json.encode(translatedMap));

//         Get.appendTranslations({
//           getxKey: translatedMap
//         });
        
//         print("Successfully cached Sales App language: $targetLangCode!");
//       }
//     } catch (e) {
//       print("Network error during translation: $e");
//     }
//   }
// }

// class LocalizationService extends GetxService {
//   static const String _languageKey = 'selected_language';
//   // static const String _googleApiKey = 'AIzaSyCNY2Kg4C7lzkaP2VSFukD5ZXsiwydOydc'; // Consider securing this later!
//   String? _googleApiKey;
//   late SharedPreferences _prefs;
//   Locale activeLocale = const Locale('en');

//   Future<LocalizationService> init() async {
//     _prefs = await SharedPreferences.getInstance();
//     String? savedLanguage = _prefs.getString(_languageKey);

//     if (savedLanguage != null) {
//       activeLocale = _getLocaleFromCode(savedLanguage);
//     } else {
//       activeLocale = const Locale('en'); 
//     }
//     return this;
//   }

//   void changeLocale(String langCode) {
//     final locale = _getLocaleFromCode(langCode);
//     Get.updateLocale(locale);
//     activeLocale = locale;
//     _prefs.setString(_languageKey, langCode);
//   }

//   Locale _getLocaleFromCode(String langCode) {
//     if (langCode.contains('-')) {
//       var parts = langCode.split('-');
//       return Locale(parts[0], parts[1]);
//     }
//     return Locale(langCode);
//   }

//   // Fetches missing translations from Google in the background
//   Future<void> fetchAndSaveTranslations(String targetLangCode) async {
//     if (targetLangCode == 'en') return;

//     try {
//       String enJsonString = await rootBundle.loadString('assets/locales/en.json');
//       Map<String, dynamic> enMap = json.decode(enJsonString);

//       List<String> keys = enMap.keys.toList();
//       List<String> valuesToTranslate = enMap.values.map((e) => e.toString()).toList();

//       const int chunkSize = 100; 
//       List<String> allTranslatedValues = [];

//       for (int i = 0; i < valuesToTranslate.length; i += chunkSize) {
//         int end = (i + chunkSize < valuesToTranslate.length) ? i + chunkSize : valuesToTranslate.length;
//         List<String> chunk = valuesToTranslate.sublist(i, end);

//         final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$_googleApiKey');
        
//         final response = await http.post(
//           url,
//           headers: {'Content-Type': 'application/json'},
//           body: json.encode({
//             'q': chunk,
//             'source': 'en',
//             'target': targetLangCode,
//             'format': 'text'
//           }),
//         );

//         if (response.statusCode == 200) {
//           final data = json.decode(response.body);
//           final translations = data['data']['translations'] as List;
//           allTranslatedValues.addAll(translations.map((t) => t['translatedText'].toString()));
//         } else {
//           print("Translation API Error: ${response.body}");
//           return; 
//         }
//       }

//       if (allTranslatedValues.length == keys.length) {
//         Map<String, String> translatedMap = {};
//         for (int i = 0; i < keys.length; i++) {
//           translatedMap[keys[i]] = allTranslatedValues[i];
//         }

//         String getxKey = targetLangCode.replaceAll('-', '_');
//         await _prefs.setString('lang_$getxKey', json.encode(translatedMap));

//         Get.appendTranslations({
//           getxKey: translatedMap
//         });
        
//         print("Successfully cached Sales App language: $targetLangCode!");
//       }
//     } catch (e) {
//       print("Network error during translation: $e");
//     }
//   }
// }