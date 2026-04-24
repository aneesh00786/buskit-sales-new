import 'package:busskit_salesexecutive/common/localization_service.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



const List<List<String>> ALL_LANGUAGES = [
  ['en', 'English (Default)'], ['hi', 'Hindi - हिन्दी'], ['ar', 'Arabic - العربية'],
  ['zh-CN', 'Chinese Simplified - 简体中文'], ['zh-TW', 'Chinese Traditional - 繁體中文'],
  ['fr', 'French - Français'], ['de', 'German - Deutsch'], ['es', 'Spanish - Español'],
  ['pt', 'Portuguese - Português'], ['ru', 'Russian - Русский'], ['ja', 'Japanese - 日本語'],
  ['ko', 'Korean - 한국어'], ['it', 'Italian - Italiano'], ['nl', 'Dutch - Nederlands'],
  ['pl', 'Polish - Polski'], ['uk', 'Ukrainian - Українська'], ['tr', 'Turkish - Türkçe'],
  ['fa', 'Persian - فارسی'], ['he', 'Hebrew - עברית'], ['sv', 'Swedish - Svenska'],
  ['no', 'Norwegian - Norsk'], ['da', 'Danish - Dansk'], ['fi', 'Finnish - Suomi'],
  ['el', 'Greek - Ελληνικά'], ['cs', 'Czech - Čeština'], ['sk', 'Slovak - Slovenčina'],
  ['hu', 'Hungarian - Magyar'], ['ro', 'Romanian - Română'], ['bg', 'Bulgarian - Български'],
  ['hr', 'Croatian - Hrvatski'], ['sl', 'Slovenian - Slovenščina'], ['et', 'Estonian - Eesti'],
  ['lv', 'Latvian - Latviešu'], ['lt', 'Lithuanian - Lietuvių'], ['id', 'Indonesian - Bahasa Indonesia'],
  ['ms', 'Malay - Bahasa Melayu'], ['tl', 'Filipino'], ['vi', 'Vietnamese - Tiếng Việt'],
  ['th', 'Thai - ภาษาไทย'], ['km', 'Khmer - ភាសាខ្មែរ'], ['my', 'Burmese - မြန်မာဘာသာ'],
  ['ur', 'Urdu - اردو'], ['bn', 'Bengali - বাংলা'], ['si', 'Sinhala - සිංහල'],
  ['ne', 'Nepali - नेपाली'], ['am', 'Amharic - አማርኛ'], ['sw', 'Swahili - Kiswahili'],
  ['yo', 'Yoruba - Yorùbá'], ['af', 'Afrikaans'], ['zu', 'Zulu - isiZulu'],
  ['ka', 'Georgian - ქართული'], ['hy', 'Armenian - Հայերեն'], ['az', 'Azerbaijani - Azərbaycan'],
  ['kk', 'Kazakh - Қазақша'], ['uz', 'Uzbek - Ozbek'], ['mn', 'Mongolian - Монгол'],
  ['so', 'Somali - Soomaali'], ['mt', 'Maltese - Malti'], ['is', 'Icelandic - Íslenska'],
  ['be', 'Belarusian - Беларуская']
];

class SplashScreenLogging extends StatefulWidget {
  final String message;
  final VoidCallback? onSyncInBackground;

  const SplashScreenLogging({
    Key? key,
    this.message = "...",
    this.onSyncInBackground,
  }) : super(key: key);

  @override
  State<SplashScreenLogging> createState() => _SplashScreenLoggingState();
}

class _SplashScreenLoggingState extends State<SplashScreenLogging> {
  late String _selectedLanguageCode;
  bool _isTranslating = false;

@override
  void initState() {
    super.initState();
    final activeLocale = Get.find<LocalizationService>().activeLocale;
    _selectedLanguageCode = activeLocale.countryCode != null
        ? '${activeLocale.languageCode}-${activeLocale.countryCode}'
        : activeLocale.languageCode;

   
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLanguageDropdownPopup();
    });
  }
  
  Widget _buildLanguageTriggerButton() {
    String currentLangName = ALL_LANGUAGES.firstWhere(
      (lang) => lang[0] == _selectedLanguageCode,
      orElse: () => ['en', 'English (Default)'],
    )[1];

    return ElevatedButton.icon(
      onPressed: _showLanguageDropdownPopup,
      icon: const Icon(Icons.language, color: primaryColor),
      label: Text(
        currentLangName,
        style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  
void _showLanguageDropdownPopup() {
    String tempSelectedLanguage = _selectedLanguageCode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              
              alignment: Alignment.center, 
             
              insetPadding: const EdgeInsets.only(top: 60, left: 20, right: 20), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: [
                  const Icon(Icons.translate, color: primaryColor),
                  const SizedBox(width: 10),
                  Text("Select Language".tr),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Choose your preferred application language:".tr),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: tempSelectedLanguage,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    isExpanded: true,
                    menuMaxHeight: 300.0,
                    items: ALL_LANGUAGES.map((lang) {
                      return DropdownMenuItem(
                        value: lang[0],
                        child: Text(lang[1]),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          tempSelectedLanguage = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: Text("Cancel".tr, style: const TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); 
                    _handleLanguageLogic(tempSelectedLanguage); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Apply".tr),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleLanguageLogic(String newValue) async {
   
    if (newValue == _selectedLanguageCode) return; 

    final localizationService = Get.find<LocalizationService>();

    
    bool canChange = await localizationService.canChangeLanguage();
    int remaining = await localizationService.getRemainingChanges();

    if (!mounted) return;

    if (!canChange) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Limit Reached".tr),
          content: Text("You can only change the language 3 times per month. Please try again next month.".tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK".tr),
            )
          ],
        ),
      );
      return;
    }

    // 2. Show confirmation warning about the limit
    bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Change Language?".tr),
        content: SizedBox(
          height: 50,
          child: Column(
            children: [
              Text("You can only change your language 3 times a month".tr),
              Text('You have'.tr + ' $remaining ' + 'change(s) left this month. Do you want to proceed?'.tr)
              
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: Text("Cancel".tr, style: const TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Proceed
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
            child: Text("Proceed".tr),
          ),
        ],
      ),
    );

   
    if (confirm == true) {
      await localizationService.recordLanguageChange(); // Record the usage

      if (!mounted) return;
      setState(() {
        _selectedLanguageCode = newValue;
        _isTranslating = true;
      });

      localizationService.changeLocale(newValue);
      await localizationService.fetchAndSaveTranslations(newValue);

      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
      }
    }
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      
      body: SafeArea(
        child: Stack(
          children: [
           
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.language, color: Colors.white, size: 26),
                  tooltip: 'Change Language'.tr,
                  onPressed: _showLanguageDropdownPopup,
                ),
              ),
            ),

            
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        widget.message.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sync button block
                    if (widget.onSyncInBackground != null) ...[
                      ElevatedButton(
                        onPressed: widget.onSyncInBackground,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Sync in Background'.tr,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// class SplashScreenLogging extends StatelessWidget {
//   final String message;
//   final VoidCallback? onSyncInBackground;

//   const SplashScreenLogging(
//       {super.key, this.message = "...", this.onSyncInBackground});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(
//               color: white,
//             ),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.bold, color: white),
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Always show the button for testing
//             if (onSyncInBackground != null) ...[
//               ElevatedButton(
//                 onPressed: onSyncInBackground ??
//                     () {
//                     },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: primaryColor,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 ),
//                 child: Text(
//                   onSyncInBackground != null
//                       ? 'Sync in Background'
//                       : 'Sync in Background (null callback)',
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
