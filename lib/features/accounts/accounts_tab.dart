import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

import '../../core/money/currencies.dart';
import '../../core/money/money.dart';
import '../../data/providers/database_provider.dart';
import 'account_form_screen.dart';

const _assetTypes = {'cash', 'bank', 'ewallet'};
const _liabilityTypes = {'credit', 'loan', 'liability'};

/// Display order for Money Lover–style grouped list.
const _typeOrder = ['cash', 'bank', 'ewallet', 'credit', 'loan', 'liability'];

/// Accounts tab: assets/liabilities summary + accounts grouped by type.
class AccountsTab extends ConsumerWidget {
  const AccountsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accounts = ref.watch(accountsProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);

    return accounts.when(
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
                  onPress: () => _openForm(context),
                  child: Text(l10n.accountAdd),
                ),
              ],
            ),
          );
        }

        final base = baseCurrency.asData?.value ?? Currencies.defaultBase;
        final colors = context.theme.colors;

        final assetsMinor = _sumBy(
          list,
          base,
          (a) => _assetTypes.contains(a.type) || !_liabilityTypes.contains(a.type),
        );
        final liabilitiesMinor = _sumBy(
          list,
          base,
          (a) => _liabilityTypes.contains(a.type),
        );
        final totalMinor = assetsMinor - liabilitiesMinor;

        final groups = _groupAccounts(list);

        return Material(
          color: colors.background,
          child: ListView(
            children: [
              _SummaryBar(
                assets: Money(minorUnits: assetsMinor, currencyCode: base),
                liabilities:
                    Money(minorUnits: liabilitiesMinor, currencyCode: base),
                total: Money(minorUnits: totalMinor, currencyCode: base),
              ),
              for (final group in groups) ...[
                _GroupHeader(
                  title: _groupTitle(l10n, group.type),
                  subtotal: _formatGroupSubtotal(group.accounts, base),
                ),
                for (final account in group.accounts)
                  _AccountRow(
                    name: account.name,
                    balance: Money(
                      minorUnits: account.balanceMinor,
                      currencyCode: account.currencyCode,
                    ),
                    onTap: () => _openForm(context, account: account),
                  ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  static int _sumBy(
    List<Account> list,
    String base,
    bool Function(Account) include,
  ) {
    var sum = 0;
    for (final a in list) {
      if (!include(a)) continue;
      if (a.currencyCode != base) continue;
      sum += a.balanceMinor;
    }
    return sum;
  }

  static List<_AccountGroup> _groupAccounts(List<Account> list) {
    final byType = <String, List<Account>>{};
    for (final a in list) {
      byType.putIfAbsent(a.type, () => []).add(a);
    }
    for (final entries in byType.values) {
      entries.sort((a, b) => a.name.compareTo(b.name));
    }

    final ordered = <_AccountGroup>[];
    for (final type in _typeOrder) {
      final accounts = byType.remove(type);
      if (accounts == null || accounts.isEmpty) continue;
      ordered.add(_AccountGroup(type: type, accounts: accounts));
    }
    final leftovers = byType.keys.toList()..sort();
    for (final type in leftovers) {
      ordered.add(_AccountGroup(type: type, accounts: byType[type]!));
    }
    return ordered;
  }

  static String _groupTitle(AppLocalizations l10n, String type) {
    return switch (type) {
      'cash' => l10n.accountGroupCash,
      'bank' => l10n.accountGroupBank,
      'ewallet' => l10n.accountGroupEwallet,
      'credit' => l10n.accountGroupCredit,
      'loan' => l10n.accountGroupLoan,
      _ => l10n.accountGroupOther,
    };
  }

  static String? _formatGroupSubtotal(List<Account> accounts, String base) {
    final sameCurrency = accounts.every((a) => a.currencyCode == base);
    if (!sameCurrency) {
      final inBase = accounts.where((a) => a.currencyCode == base).toList();
      if (inBase.isEmpty) return null;
      final sum = inBase.fold<int>(0, (s, a) => s + a.balanceMinor);
      return Money(minorUnits: sum, currencyCode: base).format();
    }
    final sum = accounts.fold<int>(0, (s, a) => s + a.balanceMinor);
    return Money(minorUnits: sum, currencyCode: base).format();
  }

  static void _openForm(BuildContext context, {Account? account}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountFormScreen(account: account),
      ),
    );
  }
}

class _AccountGroup {
  const _AccountGroup({required this.type, required this.accounts});

  final String type;
  final List<Account> accounts;
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.assets,
    required this.liabilities,
    required this.total,
  });

  final Money assets;
  final Money liabilities;
  final Money total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    // Money Lover uses blue for assets, orange for liabilities.
    const assetsColor = Color(0xFF1E88E5);
    const liabilitiesColor = Color(0xFFE65100);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCell(
              label: l10n.accountsAssets,
              value: assets.format(),
              valueColor: assetsColor,
            ),
          ),
          Container(width: 1, height: 36, color: colors.border),
          Expanded(
            child: _SummaryCell(
              label: l10n.accountsLiabilities,
              value: liabilities.format(),
              valueColor: liabilitiesColor,
            ),
          ),
          Container(width: 1, height: 36, color: colors.border),
          Expanded(
            child: _SummaryCell(
              label: l10n.accountsTotal,
              value: total.format(),
              valueColor: colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Column(
      children: [
        Text(
          label,
          style: context.theme.typography.body.sm.copyWith(
            color: colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.md.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title, this.subtotal});

  final String title;
  final String? subtotal;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    const subtotalColor = Color(0xFF1E88E5);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.foreground,
              ),
            ),
          ),
          if (subtotal != null)
            Text(
              subtotal!,
              style: context.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
                color: subtotalColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.name,
    required this.balance,
    required this.onTap,
  });

  final String name;
  final Money balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 14, 16, 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: context.theme.typography.body.md.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ),
            Text(
              balance.format(),
              style: context.theme.typography.body.md.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
