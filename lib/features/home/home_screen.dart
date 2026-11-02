import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

import '../../core/money/money.dart';
import '../../data/providers/database_provider.dart';
import '../../domain/enums/ledger_event_type.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accounts = ref.watch(accountsProvider);
    final recent = ref.watch(recentEventsProvider);
    final spend = ref.watch(monthSpendStubProvider);

    return ListView(
      children: [
        Text(
          l10n.homeWelcome,
          style: context.theme.typography.display.lg.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.homeSubtitle,
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.homeThisMonth,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        spend.when(
          loading: () => const FProgress(),
          error: (e, _) => Text('$e'),
          data: (stub) {
            final total = Money(
              minorUnits: stub.totalExpenseMinor,
              currencyCode: stub.baseCurrency,
            ).format();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total,
                  style: context.theme.typography.display.xl.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (stub.topCategories.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.homeTopCategories,
                    style: context.theme.typography.body.sm.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final cat in stub.topCategories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '${cat.name} · ${Money(minorUnits: cat.amountMinor, currencyCode: stub.baseCurrency).format()}',
                      ),
                    ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          l10n.homeAccounts,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        accounts.when(
          loading: () => const FProgress(),
          error: (e, _) => Text('$e'),
          data: (list) {
            if (list.isEmpty) {
              return Text(l10n.homeEmptyAccounts);
            }
            return FTileGroup(
              children: [
                for (final account in list)
                  FTile(
                    title: Text(account.name),
                    subtitle: Text(account.currencyCode),
                    suffix: Text(
                      Money(
                        minorUnits: account.balanceMinor,
                        currencyCode: account.currencyCode,
                      ).format(),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          l10n.homeRecent,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        recent.when(
          loading: () => const FProgress(),
          error: (e, _) => Text('$e'),
          data: (events) {
            if (events.isEmpty) {
              return Text(l10n.homeNoEvents);
            }
            final accountNames = {
              for (final a in accounts.asData?.value ?? <Account>[]) a.id: a.name,
            };
            return FTileGroup(
              children: [
                for (final event in events)
                  FTile(
                    title: Text(_eventTitle(l10n, event)),
                    subtitle: Text(
                      accountNames[event.accountId] ??
                          event.accountId ??
                          event.currencyCode,
                    ),
                    suffix: Text(
                      Money(
                        minorUnits: event.amountMinor,
                        currencyCode: event.currencyCode,
                      ).format(),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _eventTitle(AppLocalizations l10n, LedgerEvent event) {
    if (event.eventType == LedgerEventType.expense.storageKey) {
      return l10n.captureTypeExpense;
    }
    if (event.eventType == LedgerEventType.income.storageKey) {
      return l10n.captureTypeIncome;
    }
    if (event.eventType == LedgerEventType.transfer.storageKey) {
      return l10n.captureTypeTransfer;
    }
    if (event.eventType == LedgerEventType.openingBalance.storageKey) {
      return l10n.accountOpeningBalance;
    }
    return event.eventType;
  }
}
