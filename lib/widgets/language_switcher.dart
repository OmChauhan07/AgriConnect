import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_connect/l10n/app_localizations.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/localization_helper.dart';
import 'package:agri_connect/providers/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool isDashboard;

  const LanguageSwitcher({
    Key? key,
    this.isDashboard = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return PopupMenuButton<String>(
      tooltip: LocalizedStrings.get(context, 'changeLanguage'),
      icon: Icon(
        Icons.language,
        color: isDashboard ? Colors.white : AppColors.primaryColor,
      ),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onSelected: (String languageCode) {
        _changeLanguage(context, languageCode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: _buildLanguageItem(
            context,
            'English',
            'en',
            localizations.locale.languageCode == 'en',
          ),
        ),
        PopupMenuItem<String>(
          value: 'hi',
          child: _buildLanguageItem(
            context,
            'हिंदी (Hindi)',
            'hi',
            localizations.locale.languageCode == 'hi',
          ),
        ),
        PopupMenuItem<String>(
          value: 'gu',
          child: _buildLanguageItem(
            context,
            'ગુજરાતી (Gujarati)',
            'gu',
            localizations.locale.languageCode == 'gu',
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageItem(
      BuildContext context, String label, String code, bool isSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        if (isSelected)
          Icon(
            Icons.check_circle,
            color: AppColors.primaryColor,
            size: 18,
          ),
      ],
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) async {
    // Use the LocaleProvider to change the language
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.changeLanguage(languageCode);

    // Show a confirmation snackbar
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          languageCode == 'en'
              ? 'Language changed to English'
              : (languageCode == 'hi'
                  ? 'भाषा हिंदी में बदली गई'
                  : 'ભાષા ગુજરાતીમાં બદલાઈ ગઈ'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
