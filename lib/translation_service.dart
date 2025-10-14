import 'package:translator/translator.dart';

class TranslationService {
  static final translator = GoogleTranslator();
  static String currentLanguage = 'en'; // Default English
  
  // Translate any text to current language
  static Future<String> translate(String text) async {
    if (currentLanguage == 'en') return text; // No translation needed
    
    try {
      var translation = await translator.translate(
        text,
        from: 'en',
        to: currentLanguage,
      );
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text; // Return original if translation fails
    }
  }
  
  // Change app language
  static void setLanguage(String langCode) {
    currentLanguage = langCode;
  }
  
  // Get available languages
  static Map<String, String> getLanguages() {
    return {
      'en': '🇬🇧 English',
      'tr': '🇹🇷 Türkçe',
      'es': '🇪🇸 Español',
      'ar': '🇸🇦 العربية',
      'fr': '🇫🇷 Français',
      'it': '🇮🇹 Italiano',
      'el': '🇬🇷 Ελληνικά',
      'pt': '🇵🇹 Português',
    };
  }
}
