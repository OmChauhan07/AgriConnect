import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

/// ContentTranslator is responsible for translating content in the app
/// using the translator package. It provides methods to translate text
/// and determine if translation is needed based on user settings.
class ContentTranslator {
  static final ContentTranslator _instance = ContentTranslator._internal();
  final GoogleTranslator _translator = GoogleTranslator();

  // Singleton pattern
  factory ContentTranslator() => _instance;

  ContentTranslator._internal();

  /// Checks if automatic translation is enabled in preferences
  Future<bool> isAutoTranslationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('autoTranslateProductDetails') ?? false;
  }

  /// Gets the current language code from preferences
  Future<String> getCurrentLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('languageCode') ?? 'en';
  }

  /// Translates a string to the specified target language
  /// Returns the original text if:
  /// - translation is not needed (target is English or matches source)
  /// - translation fails for any reason
  /// - original text is empty
  Future<String> translateText(String text, {String? targetLanguage}) async {
    // If text is empty, return it as is
    if (text.isEmpty) return text;

    // Get target language (either specified or from preferences)
    final target = targetLanguage ?? await getCurrentLanguageCode();

    // No need to translate if the target language is English
    if (target == 'en') return text;

    // Auto translation must be enabled
    final autoTranslateEnabled = await isAutoTranslationEnabled();
    if (!autoTranslateEnabled) return text;

    try {
      final translation = await _translator.translate(
        text,
        to: target,
      );
      return translation.text;
    } catch (e) {
      debugPrint('Translation error: $e');
      return text; // Return original text on error
    }
  }

  /// Translates a collection of texts and returns a map of originals to translations
  Future<Map<String, String>> translateTexts(List<String> texts,
      {String? targetLanguage}) async {
    final results = <String, String>{};

    // Get target language (either specified or from preferences)
    final target = targetLanguage ?? await getCurrentLanguageCode();

    // No need to translate if the target language is English
    if (target == 'en') {
      for (final text in texts) {
        results[text] = text;
      }
      return results;
    }

    // Auto translation must be enabled
    final autoTranslateEnabled = await isAutoTranslationEnabled();
    if (!autoTranslateEnabled) {
      for (final text in texts) {
        results[text] = text;
      }
      return results;
    }

    for (final text in texts) {
      if (text.isNotEmpty) {
        try {
          final translation = await _translator.translate(
            text,
            to: target,
          );
          results[text] = translation.text;
        } catch (e) {
          debugPrint('Translation error for "$text": $e');
          results[text] = text; // Return original text on error
        }
      } else {
        results[text] = text;
      }
    }

    return results;
  }

  /// Helper method to determine if translation might be needed
  /// based on the current language and auto-translate setting
  Future<bool> needsTranslation() async {
    final langCode = await getCurrentLanguageCode();
    final autoTranslate = await isAutoTranslationEnabled();

    // Only need translation if language is not English and auto-translate is on
    return langCode != 'en' && autoTranslate;
  }
}
