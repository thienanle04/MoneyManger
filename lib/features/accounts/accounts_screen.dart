import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

import '../../core/money/money.dart';
import '../../data/providers/database_provider.dart';
import 'account_form_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accounts = ref.watch(accountsProvider);

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.settingsAccounts),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).pop()),
        ],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.plus),
            onPress: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AccountFormScreen(),
              ),
            ),
          ),
        ],
      ),
      child: accounts.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.homeEmptyAccounts),
                  const SizedBox(height: 16),
                  FButton(
                    onPress: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AccountFormScreen(),
                      ),
                    ),
                    child: Text(l10n.accountAdd),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: [
              FTileGroup(
                children: [
                  for (final account in list)
                    FTile(
                      title: Text(account.name),
                      subtitle: Text(
                        Money(
                          minorUnits: account.balanceMinor,
                          currencyCode: account.currencyCode,
                        ).format(),
                      ),
                      onPress: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AccountFormScreen(account: account),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
