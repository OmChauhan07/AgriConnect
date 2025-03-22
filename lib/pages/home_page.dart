import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_switcher.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('appTitle')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              localizations.translate('welcome'),
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(localizations.translate('home')),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(localizations.translate('about')),
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: Text(localizations.translate('contact')),
            ),
            const SizedBox(height: 40),
            const LanguageSwitcher(),
          ],
        ),
      ),
    );
  }
}
