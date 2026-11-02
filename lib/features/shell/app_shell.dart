import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

import '../../data/providers/database_provider.dart';
import '../accounts/account_form_screen.dart';
import '../accounts/accounts_tab.dart';
import '../home/home_screen.dart';
import '../insights/insights_screen.dart';
import '../settings/settings_screen.dart';
import '../transactions/transactions_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  /// Home sits in the center of a 5-tab bar.
  int _index = 2;

  static const _screens = [
    TransactionsScreen(),
    InsightsScreen(),
    HomeScreen(),
    AccountsTab(),
    SettingsScreen(),
  ];

  String _title(AppLocalizations l10n) {
    return switch (_index) {
      0 => l10n.navTrans,
      1 => l10n.navInsights,
      2 => l10n.navHome,
      3 => l10n.navAccounts,
      _ => l10n.navMore,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final ready = ref.watch(appReadyProvider);
    final onTrans = _index == 0;

    return FScaffold(
      // Trans. owns its full-bleed header; other tabs keep page padding.
      childPad: !onTrans,
      header: onTrans
          ? null
          : ColoredBox(
              color: colors.primary,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _title(l10n),
                            style: context.theme.typography.body.lg.copyWith(
                              color: colors.primaryForeground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_index == 3) ...[
                          IconButton(
                            onPressed: () => setState(() => _index = 1),
                            icon: Icon(
                              FLucideIcons.chartColumn,
                              color: colors.primaryForeground,
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.accountAdd,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const AccountFormScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              FLucideIcons.plus,
                              color: colors.primaryForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
      footer: FBottomNavigationBar(
        index: _index,
        onChange: (index) => setState(() => _index = index),
        children: [
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.receipt),
            label: Text(l10n.navTrans),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.chartLine),
            label: Text(l10n.navInsights),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.house),
            label: Text(l10n.navHome),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.wallet),
            label: Text(l10n.navAccounts),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.ellipsis),
            label: Text(l10n.navMore),
          ),
        ],
      ),
      child: ready.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (e, _) => Center(child: Text('$e')),
        data: (_) => IndexedStack(
          index: _index,
          children: _screens,
        ),
      ),
    );
  }
}
