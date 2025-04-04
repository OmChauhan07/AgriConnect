import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/providers/locale_provider.dart';
import 'package:agri_connect/screens/onboarding/login_screen.dart';
import 'package:agri_connect/utils/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_switcher.dart';
import '../../main.dart'; // Import main.dart to access MyApp
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/localization_helper.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Language Switcher at the top right
              Align(
                alignment: Alignment.topRight,
                child: _buildLanguageSwitcher(context),
              ),
              const SizedBox(height: 20),

              // App Logo and Title
              Text(
                LocalizedStrings.appName(context),
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                LocalizedStrings.welcome(context),
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Role Selection
              Text(
                LocalizedStrings.chooseRole(context),
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),

              // Role Cards
              Row(
                children: [
                  Expanded(
                    child: _buildRoleCard(
                      context,
                      title: LocalizedStrings.farmer(context),
                      iconPath: 'assets/farmer_icon.svg',
                      role: UserRole.farmer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRoleCard(
                      context,
                      title: LocalizedStrings.consumer(context),
                      iconPath: 'assets/consumer_icon.svg',
                      role: UserRole.consumer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context) {
    // Create a simpler language switcher for the landing page
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => _changeLanguage(context, 'en'),
          child: const Text('EN'),
        ),
        TextButton(
          onPressed: () => _changeLanguage(context, 'hi'),
          child: const Text('हिं'),
        ),
        TextButton(
          onPressed: () => _changeLanguage(context, 'gu'),
          child: const Text('ગુજ'),
        ),
      ],
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) async {
    // Use the LocaleProvider to change the language
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.changeLanguage(languageCode);
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String iconPath,
    required UserRole role,
  }) {
    // For prototype, we'll use network SVGs since we can't use local assets
    String networkSvgUrl = role == UserRole.farmer
        ? 'https://cdn-icons-png.flaticon.com/512/1146/1146869.png'
        : 'https://cdn-icons-png.flaticon.com/512/1077/1077063.png';

    return GestureDetector(
      onTap: () {
        Provider.of<AuthProvider>(context, listen: false).setSelectedRole(role);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGreen,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor, width: 1),
              ),
              child: Image.network(networkSvgUrl),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
