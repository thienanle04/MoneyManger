import 'package:flutter/material.dart';
import 'package:money_manager/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.settingsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(l10n.baseCurrency),
            subtitle: const Text('VND'),
            leading: const Icon(Icons.payments_outlined),
          ),
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(l10n.languageSystem),
            leading: const Icon(Icons.language_outlined),
          ),
        ],
      ),
    );
  }
}
