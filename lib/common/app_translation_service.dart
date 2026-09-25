
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTranslations extends Translations {
  final Map<String, Map<String, String>> loadedTranslations;

  AppTranslations(this.loadedTranslations);

  @override
  Map<String, Map<String, String>> get keys => loadedTranslations;

  static Future<AppTranslations> init() async {
    Map<String, Map<String, String>> finalTranslations = {};
    final prefs = await SharedPreferences.getInstance();

<<<<<<< HEAD
    // 1. Always load English as the base
    Set<String> localesToLoad = {'en'};

    // 2. Add the currently saved language so GetX loads it immediately
    String? savedLanguage = prefs.getString('selected_language');
    if (savedLanguage != null && savedLanguage.isNotEmpty) {
      localesToLoad.add(savedLanguage);
    }

    for (String locale in localesToLoad) {
=======
    // Your list of supported languages
    List<String> locales = [
      'en',
      'hi',
      'ar',
      'zh-CN',
      'zh-TW',
      'fr',
      'de',
      'es',
      'pt',
      'ru',
      'ja',
      'ko',
      'it',
      'nl',
      'pl',
      'uk',
      'tr',
      'fa',
      'he',
      'sv',
      'no',
      'da',
      'fi',
      'el',
      'cs',
      'sk',
      'hu',
      'ro',
      'bg',
      'hr',
      'sl',
      'et',
      'lv',
      'lt',
      'id',
      'ms',
      'tl',
      'vi',
      'th',
      'km',
      'my',
      'ur',
      'bn',
      'si',
      'ne',
      'am',
      'sw',
      'yo',
      'af',
      'zu',
      'ka',
      'hy',
      'az',
      'kk',
      'uz',
      'mn',
      'so',
      'mt',
      'is',
      'be'
    ];
    // List<String> locales = ['en', 'hi', 'zh-CN', 'ar' , ];

    for (String locale in locales) {
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
      String getxKey = locale.replaceAll('-', '_');

      // 1. Check Offline Database (SharedPreferences) FIRST
      String? savedJson = prefs.getString('lang_$getxKey');

      if (savedJson != null) {
<<<<<<< HEAD
        try {
          Map<String, dynamic> decodedMap = json.decode(savedJson);
          finalTranslations[getxKey] =
              decodedMap.map((key, value) => MapEntry(key, value.toString()));
          continue;
        } catch (_) {}
      }

      // 2. Fallback to bundled assets
      try {
        String jsonString =
            await rootBundle.loadString('assets/locales/$locale.json');
        Map<String, dynamic> jsonMap = json.decode(jsonString);
        finalTranslations[getxKey] =
            jsonMap.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        finalTranslations[getxKey] = {};
=======
        // Use the API-translated database version
        Map<String, dynamic> decodedMap = json.decode(savedJson);
        finalTranslations[getxKey] =
            decodedMap.map((key, value) => MapEntry(key, value.toString()));
      } else {
        // 2. Fallback to bundled assets if first launch or database is empty
        try {
          String jsonString =
              await rootBundle.loadString('assets/locales/$locale.json');
          Map<String, dynamic> jsonMap = json.decode(jsonString);
          finalTranslations[getxKey] =
              jsonMap.map((key, value) => MapEntry(key, value.toString()));
        } catch (e) {
          // If the asset file doesn't exist, provide an empty map to prevent crashes
          finalTranslations[getxKey] = {};
        }
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
      }
    }

    return AppTranslations(finalTranslations);
  }
}

// class AppTranslations extends Translations {
//   final Map<String, Map<String, String>> loadedTranslations;

//   AppTranslations(this.loadedTranslations);

//   @override
//   Map<String, Map<String, String>> get keys => loadedTranslations;

//   static Future<AppTranslations> init() async {
//     Map<String, Map<String, String>> finalTranslations = {};
//     final prefs = await SharedPreferences.getInstance();

//     // 1. Always load English as the base
//     List<String> locales = ['en']; 

//     // 2. NEW LOGIC: Add the currently saved language so GetX loads it!
//     String? savedLanguage = prefs.getString('selected_language');
//     if (savedLanguage != null && savedLanguage != 'en') {
//       locales.add(savedLanguage);
//     }

//     for (String locale in locales) {
//       String getxKey = locale.replaceAll('-', '_');
      
//       // Check Offline Database FIRST
//       String? savedJson = prefs.getString('lang_$getxKey');

//       if (savedJson != null) {
//         Map<String, dynamic> decodedMap = json.decode(savedJson);
//         finalTranslations[getxKey] = decodedMap.map((key, value) => MapEntry(key, value.toString()));
//       } else if (locale == 'en') {
//         // Only fallback to assets for 'en' because we don't have json files for other languages
//         try {
//           String jsonString = await rootBundle.loadString('assets/locales/$locale.json');
//           Map<String, dynamic> jsonMap = json.decode(jsonString);
//           finalTranslations[getxKey] = jsonMap.map((key, value) => MapEntry(key, value.toString()));
//         } catch (e) {
//           finalTranslations[getxKey] = {};
//         }
//       }
//     }

//     return AppTranslations(finalTranslations);
//   }
// }