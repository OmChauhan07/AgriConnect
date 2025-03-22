import 'package:flutter/material.dart';
import 'package:agri_connect/l10n/app_localizations.dart';
import 'package:agri_connect/services/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A utility class to help access localized strings more easily
class LocalizedStrings {
  /// Gets a localized string by key
  static String get(BuildContext context, String key) {
    return AppLocalizations.of(context).translate(key);
  }

  /// Translates a given text using the TranslationService
  static Future<String> translate(String text, {String? targetLanguage}) async {
    return await TranslationService()
        .translateText(text, targetLanguage: targetLanguage);
  }

  /// Checks if auto translation is enabled in preferences
  static Future<bool> isAutoTranslationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('autoTranslateProductDetails') ?? false;
  }

  /// Translates text if auto translation is enabled and the current language is not English
  static Future<String> translateIfNeeded(String text) async {
    if (await isAutoTranslationEnabled() &&
        await TranslationService().needsTranslation()) {
      return await translate(text);
    }
    return text;
  }

  // Common UI elements
  static String appTitle(BuildContext context) => get(context, 'appTitle');
  static String searchHint(BuildContext context) => get(context, 'searchHint');

  // Landing screen
  static String appName(BuildContext context) => get(context, 'appTitle');
  static String welcome(BuildContext context) => get(context, 'welcome');
  static String chooseRole(BuildContext context) => get(context, 'chooseRole');

  // Authentication related
  static String login(BuildContext context) => get(context, 'login');
  static String signup(BuildContext context) => get(context, 'signup');
  static String register(BuildContext context) => get(context, 'signup');
  static String email(BuildContext context) => get(context, 'email');
  static String password(BuildContext context) => get(context, 'password');
  static String forgotPassword(BuildContext context) =>
      get(context, 'forgotPassword');
  static String dontHaveAccount(BuildContext context) =>
      get(context, 'dontHaveAccount');
  static String alreadyHaveAccount(BuildContext context) =>
      get(context, 'alreadyHaveAccount');
  static String name(BuildContext context) => get(context, 'name');
  static String phoneNumber(BuildContext context) =>
      get(context, 'phoneNumber');
  static String confirmPassword(BuildContext context) =>
      get(context, 'confirmPassword');

  // User types
  static String consumer(BuildContext context) => get(context, 'consumer');
  static String farmer(BuildContext context) => get(context, 'farmer');

  // Validation messages
  static String invalidEmail(BuildContext context) =>
      get(context, 'invalidEmail');
  static String passwordTooShort(BuildContext context) =>
      get(context, 'passwordTooShort');
  static String passwordsDoNotMatch(BuildContext context) =>
      get(context, 'passwordsDoNotMatch');
  static String pleaseEnterName(BuildContext context) =>
      get(context, 'pleaseEnterName');

  // Welcome screens
  static String welcomeBack(BuildContext context) =>
      get(context, 'welcomeBack');
  static String signInToContinue(BuildContext context) =>
      get(context, 'signInToContinue');
  static String createAccount(BuildContext context) =>
      get(context, 'createAccount');
  static String fillDetails(BuildContext context) =>
      get(context, 'fillDetails');
  static String getStarted(BuildContext context) => get(context, 'getStarted');
  static String continueAsGuest(BuildContext context) =>
      get(context, 'continueAsGuest');

  // Navigation items
  static String home(BuildContext context) => get(context, 'home');
  static String categories(BuildContext context) => get(context, 'categories');
  static String orders(BuildContext context) => get(context, 'orders');
  static String profile(BuildContext context) => get(context, 'profile');

  // Home screen sections
  static String exploreCategories(BuildContext context) =>
      get(context, 'exploreCategories');
  static String viewAll(BuildContext context) => get(context, 'viewAll');
  static String topRated(BuildContext context) => get(context, 'topRated');
  static String nearbyFarmers(BuildContext context) =>
      get(context, 'nearbyFarmers');
  static String recentlyAdded(BuildContext context) =>
      get(context, 'recentlyAdded');

  // Category names
  static String fruitVegetables(BuildContext context) =>
      get(context, 'fruitVegetables');
  static String dairy(BuildContext context) => get(context, 'dairy');
  static String grains(BuildContext context) => get(context, 'grains');
  static String herbs(BuildContext context) => get(context, 'herbs');

  // Product details screen
  static String productDetails(BuildContext context) =>
      get(context, 'productDetails');
  static String perUnit(BuildContext context, String unit) =>
      get(context, 'perUnit').replaceAll('{unit}', unit);
  static String ratingText(BuildContext context) => get(context, 'rating');
  static String verified(BuildContext context) => get(context, 'verified');
  static String viewProfile(BuildContext context) =>
      get(context, 'viewProfile');
  static String description(BuildContext context) =>
      get(context, 'description');
  static String productVerified(BuildContext context) =>
      get(context, 'productVerified');
  static String productVerifiedDescription(BuildContext context) =>
      get(context, 'productVerifiedDescription');
  static String scanToVerify(BuildContext context) =>
      get(context, 'scanToVerify');
  static String quantity(BuildContext context) => get(context, 'quantity');

  static String availableQuantity(
          BuildContext context, String quantity, String unit) =>
      get(context, 'availableQuantity')
          .replaceAll('{quantity}', quantity)
          .replaceAll('{unit}', unit);

  static String totalPrice(BuildContext context) => get(context, 'totalPrice');
  static String invalidQuantity(BuildContext context) =>
      get(context, 'invalidQuantity');

  static String addedToCart(BuildContext context, String product) =>
      get(context, 'addedToCart').replaceAll('{product}', product);

  static String viewCart(BuildContext context) => get(context, 'viewCart');
  static String addToCart(BuildContext context) => get(context, 'addToCart');

  // Farmer details
  static String aboutFarm(BuildContext context) => get(context, 'aboutFarm');
  static String noDescriptionAvailable(BuildContext context) =>
      get(context, 'noDescriptionAvailable');
  static String contactInformation(BuildContext context) =>
      get(context, 'contactInformation');
  static String featureNotAvailable(BuildContext context) =>
      get(context, 'featureNotAvailable');
  static String viewAllProducts(BuildContext context) =>
      get(context, 'viewAllProducts');

  // Error messages
  static String somethingWentWrong(BuildContext context) =>
      get(context, 'somethingWentWrong');
  static String tryAgain(BuildContext context) => get(context, 'tryAgain');
  static String networkError(BuildContext context) =>
      get(context, 'networkError');
}
