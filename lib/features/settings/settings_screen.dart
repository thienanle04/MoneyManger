import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/core/money/currencies.dart';
import 'package:money_manager/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FTileGroup(
      children: [
        FTile(
          prefix: const Icon(FLucideIcons.banknote),
          title: Text(l10n.baseCurrency),
          subtitle: Text(Currencies.defaultBase),
        ),
        FTile(
          prefix: const Icon(FLucideIcons.languages),
          title: Text(l10n.language),
          subtitle: Text(l10n.languageSystem),
        ),
      ],
    );
  }
}
