import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service class that handles translation of text between different languages
class TranslationService {
  static final GoogleTranslator _translator = GoogleTranslator();
  static final TranslationService _instance = TranslationService._internal();
  String? _cachedLanguageCode;

  // Factory constructor
  factory TranslationService() {
    return _instance;
  }

  // Private constructor
  TranslationService._internal() {
    // Initialize cached language code
    _initLanguageCode();
  }

  // Initialize the cached language code
  void _initLanguageCode() async {
    _cachedLanguageCode = await _getCurrentLanguageCode();
  }

  /// Get the current language code from shared preferences
  Future<String> _getCurrentLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('languageCode') ?? 'en';
    _cachedLanguageCode = code;
    return code;
  }

  /// Get the current language code synchronously (from cache)
  String getCurrentLanguageCodeSync() {
    return _cachedLanguageCode ?? 'en';
  }

  /// Update the cached language code when it changes
  void updateLanguageCode(String languageCode) {
    _cachedLanguageCode = languageCode;
  }

  /// Translate a text to the target language
  Future<String> translateText(String text, {String? targetLanguage}) async {
    // Get current language code if target language is not specified
    final languageCode = targetLanguage ?? await _getCurrentLanguageCode();

    // If language is English or the text is empty, return the original text
    if (languageCode == 'en' || text.isEmpty) {
      return text;
    }

    try {
      // Translate the text to the target language
      final translation = await _translator.translate(
        text,
        from: 'en',
        to: languageCode,
      );

      return translation.text;
    } catch (e) {
      debugPrint('Translation error: $e');
      // Return original text if translation fails
      return text;
    }
  }

  /// Translate multiple texts at once and return them as a Map
  Future<Map<String, String>> translateTexts(List<String> texts,
      {String? targetLanguage}) async {
    final Map<String, String> translatedTexts = {};

    for (final text in texts) {
      final translatedText =
          await translateText(text, targetLanguage: targetLanguage);
      translatedTexts[text] = translatedText;
    }

    return translatedTexts;
  }

  /// Check if the current language is not English
  Future<bool> needsTranslation() async {
    final languageCode = await _getCurrentLanguageCode();
    return languageCode != 'en';
  }
}
