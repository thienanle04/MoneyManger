import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

import '../../core/money/currencies.dart';
import '../../data/providers/database_provider.dart';
import '../accounts/accounts_screen.dart';
import '../categories/categories_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final baseCurrency = ref.watch(baseCurrencyProvider);

    return ListView(
      children: [
        FTileGroup(
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.wallet),
              title: Text(l10n.settingsManageAccounts),
              onPress: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AccountsScreen(),
                ),
              ),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.folder),
              title: Text(l10n.settingsManageCategories),
              onPress: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CategoriesScreen(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FTileGroup(
          children: [
            baseCurrency.when(
              loading: () => FTile(
                prefix: const Icon(FLucideIcons.banknote),
                title: Text(l10n.baseCurrency),
                subtitle: Text(Currencies.defaultBase),
              ),
              error: (e, _) => FTile(
                prefix: const Icon(FLucideIcons.banknote),
                title: Text(l10n.baseCurrency),
                subtitle: Text('$e'),
              ),
              data: (code) => FTile(
                prefix: const Icon(FLucideIcons.banknote),
                title: Text(l10n.baseCurrency),
                subtitle: Text(code),
                onPress: () => _pickBaseCurrency(context, ref, code),
              ),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.languages),
              title: Text(l10n.language),
              subtitle: Text(l10n.languageSystem),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.coins),
              title: Text(l10n.supportedCurrencies),
              subtitle: Text(l10n.currencyCount(Currencies.supported.length)),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickBaseCurrency(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            children: [
              for (final code in Currencies.codes)
                ListTile(
                  title: Text(code),
                  trailing: code == current
                      ? const Icon(FLucideIcons.check)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(code),
                ),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == current) return;
    final db = ref.read(appDatabaseProvider);
    await setBaseCurrency(db, selected);
    if (context.mounted) {
      showFToast(
        context: context,
        title: Text('${l10n.baseCurrency}: $selected'),
      );
    }
  }
}
