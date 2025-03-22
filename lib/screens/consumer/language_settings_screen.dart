import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/widgets/language_switcher.dart';
import 'package:agri_connect/l10n/app_localizations.dart';
import 'package:agri_connect/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_connect/utils/localization_helper.dart';
import 'package:agri_connect/services/translation_service.dart';
import 'package:agri_connect/providers/locale_provider.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  bool _autoTranslateProductDetails = false;
  String _currentLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _autoTranslateProductDetails =
          prefs.getBool('autoTranslateProductDetails') ?? false;

      final languageCode = prefs.getString('languageCode') ?? 'en';
      _currentLanguage = _getLanguageName(languageCode);
    });
  }

  String _getLanguageName(String code) {
    // Use BuildContext from the widget when available
    BuildContext? currentContext = context;

    // Fallback if not mounted yet
    if (!mounted || currentContext == null) {
      switch (code) {
        case 'en':
          return 'English';
        case 'hi':
          return 'हिंदी (Hindi)';
        case 'gu':
          return 'ગુજરાતી (Gujarati)';
        default:
          return 'English';
      }
    }

    switch (code) {
      case 'en':
        return LocalizedStrings.get(currentContext, 'english');
      case 'hi':
        return LocalizedStrings.get(currentContext, 'hindi');
      case 'gu':
        return LocalizedStrings.get(currentContext, 'gujarati');
      default:
        return LocalizedStrings.get(currentContext, 'english');
    }
  }

  Future<void> _toggleAutoTranslate(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoTranslateProductDetails', value);

    setState(() {
      _autoTranslateProductDetails = value;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value
            ? LocalizedStrings.get(context, 'translationEnabled')
            : LocalizedStrings.get(context, 'translationDisabled')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizedStrings.get(context, 'language')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Language
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizedStrings.get(context, 'currentLanguage'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currentLanguage,
                          style: const TextStyle(fontSize: 16),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.language),
                          label: Text(
                              LocalizedStrings.get(context, 'changeLanguage')),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  _buildLanguageDialog(context),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Auto Translation Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizedStrings.get(context, 'translationSettings'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(LocalizedStrings.get(
                          context, 'autoTranslateContent')),
                      subtitle: Text(LocalizedStrings.get(
                          context, 'autoTranslateDescription')),
                      value: _autoTranslateProductDetails,
                      activeColor: AppColors.primaryColor,
                      onChanged: _toggleAutoTranslate,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LocalizedStrings.get(context, 'translationDisclaimer'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greyColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDialog(BuildContext context) {
    return SimpleDialog(
      title: Text(LocalizedStrings.get(context, 'selectLanguage')),
      children: [
        SimpleDialogOption(
          onPressed: () => _selectLanguage(context, 'en'),
          child: _buildLanguageOption(
              LocalizedStrings.get(context, 'english'), 'en'),
        ),
        SimpleDialogOption(
          onPressed: () => _selectLanguage(context, 'hi'),
          child: _buildLanguageOption(
              LocalizedStrings.get(context, 'hindi'), 'hi'),
        ),
        SimpleDialogOption(
          onPressed: () => _selectLanguage(context, 'gu'),
          child: _buildLanguageOption(
              LocalizedStrings.get(context, 'gujarati'), 'gu'),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String label, String code) {
    final currentCode = _getCurrentLanguageCode();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  code == currentCode ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (code == currentCode)
            Icon(
              Icons.check_circle,
              color: AppColors.primaryColor,
            ),
        ],
      ),
    );
  }

  String _getCurrentLanguageCode() {
    final locale = AppLocalizations.of(context).locale;
    return locale.languageCode;
  }

  void _selectLanguage(BuildContext context, String languageCode) async {
    Navigator.pop(context);

    // Use the LocaleProvider to change the language
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.changeLanguage(languageCode);

    setState(() {
      _currentLanguage = _getLanguageName(languageCode);
    });

    // Show a confirmation snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LocalizedStrings.get(context, 'languageChanged'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
