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
  
  String? _googleApiKey; 
  
  late SharedPreferences _prefs;
  Locale activeLocale = const Locale('en');

  Future<LocalizationService> init() async {
    _prefs = await SharedPreferences.getInstance();
    String? savedLanguage = _prefs.getString(_languageKey);

    if (savedLanguage != null) {
      activeLocale = _getLocaleFromCode(savedLanguage);
    } else {
      activeLocale = const Locale('en'); 
    }
    
    await _fetchConfig(); 
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

  // UPDATED: Using ApiConstants to build the URL
  Future<void> _fetchConfig() async {
    if (_googleApiKey != null && _googleApiKey!.isNotEmpty) return;

    try {
      // Combines "https://test.thrivewoo.com/" + "config"
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.config}');
      final response = await http.get(url);

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

  Future<void> fetchAndSaveTranslations(String targetLangCode) async {
    if (targetLangCode == 'en') return;

    await _fetchConfig();
    
    if (_googleApiKey == null || _googleApiKey!.isEmpty) {
      print("Translation aborted: Google API Key is missing.");
      return;
    }

    try {
      String enJsonString = await rootBundle.loadString('assets/locales/en.json');
      Map<String, dynamic> enMap = json.decode(enJsonString);

      List<String> keys = enMap.keys.toList();
      List<String> valuesToTranslate = enMap.values.map((e) => e.toString()).toList();

      const int chunkSize = 100; 
      List<String> allTranslatedValues = [];

      for (int i = 0; i < valuesToTranslate.length; i += chunkSize) {
        int end = (i + chunkSize < valuesToTranslate.length) ? i + chunkSize : valuesToTranslate.length;
        List<String> chunk = valuesToTranslate.sublist(i, end);

        final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$_googleApiKey');
        
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'q': chunk,
            'source': 'en',
            'target': targetLangCode,
            'format': 'text'
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final translations = data['data']['translations'] as List;
          allTranslatedValues.addAll(translations.map((t) => t['translatedText'].toString()));
        } else {
          print("Translation API Error: ${response.body}");
          return; 
        }
      }

      if (allTranslatedValues.length == keys.length) {
        Map<String, String> translatedMap = {};
        for (int i = 0; i < keys.length; i++) {
          translatedMap[keys[i]] = allTranslatedValues[i];
        }

        String getxKey = targetLangCode.replaceAll('-', '_');
        await _prefs.setString('lang_$getxKey', json.encode(translatedMap));

        Get.appendTranslations({
          getxKey: translatedMap
        });
        
        print("Successfully cached Sales App language: $targetLangCode!");
      }
    } catch (e) {
      print("Network error during translation: $e");
    }
  }
}

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