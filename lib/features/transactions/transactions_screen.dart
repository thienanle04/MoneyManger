import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

import '../../core/money/money.dart';
import '../../data/providers/database_provider.dart';
import '../../domain/enums/ledger_event_type.dart';
import '../capture/capture_providers.dart';
import '../capture/capture_screen.dart';

/// Money Lover–style Trans. tab: month summary + daily list + FAB to capture.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  Future<void> _openCapture() {
    return showCaptureSheet(context);
  }

  String _monthLabel() {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${names[_month.month - 1]} ${_month.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final eventsAsync = ref.watch(transactionEventsProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoriesProvider(null));
    final baseAsync = ref.watch(baseCurrencyProvider);

    final base = baseAsync.asData?.value ?? 'VND';
    final accounts = {
      for (final a in accountsAsync.asData?.value ?? <Account>[]) a.id: a,
    };
    final categories = {
      for (final c in categoriesAsync.asData?.value ?? <Category>[]) c.id: c,
    };

    return Material(
      color: colors.background,
      child: Column(
        children: [
          ColoredBox(
            color: colors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 10),
                child: Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _shiftMonth(-1),
                      icon: Icon(
                        FLucideIcons.chevronLeft,
                        color: colors.primaryForeground,
                      ),
                    ),
                    Text(
                      _monthLabel(),
                      style: context.theme.typography.body.lg.copyWith(
                        color: colors.primaryForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _shiftMonth(1),
                      icon: Icon(
                        FLucideIcons.chevronRight,
                        color: colors.primaryForeground,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        ref
                            .read(captureRepeatTriggerProvider.notifier)
                            .state++;
                        await showCaptureSheet(context);
                      },
                      tooltip: l10n.captureRepeatLast,
                      icon: Icon(
                        FLucideIcons.star,
                        color: colors.primaryForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: FCircularProgress()),
              error: (e, _) => Center(child: Text('$e')),
              data: (allEvents) {
                final start = _month;
                final end = DateTime(_month.year, _month.month + 1);
                final monthEvents = allEvents
                    .where(
                      (e) =>
                          !e.occurredAt.isBefore(start) &&
                          e.occurredAt.isBefore(end),
                    )
                    .toList();

                var income = 0;
                var expense = 0;
                for (final e in monthEvents) {
                  if (e.currencyCode != base) continue;
                  if (e.eventType == LedgerEventType.income.storageKey) {
                    income += e.amountMinor;
                  } else if (e.eventType ==
                      LedgerEventType.expense.storageKey) {
                    expense += e.amountMinor;
                  }
                }
                final total = income - expense;

                final groups = <DateTime, List<LedgerEvent>>{};
                for (final e in monthEvents) {
                  final day = DateTime(
                    e.occurredAt.year,
                    e.occurredAt.month,
                    e.occurredAt.day,
                  );
                  (groups[day] ??= []).add(e);
                }
                final days = groups.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return Stack(
                  children: [
                    Column(
                      children: [
                        _MonthSummary(
                          income: Money(minorUnits: income, currencyCode: base)
                              .format(),
                          expense: Money(
                            minorUnits: expense,
                            currencyCode: base,
                          ).format(),
                          total: Money(minorUnits: total, currencyCode: base)
                              .format(),
                          incomeLabel: l10n.captureTypeIncome,
                          expenseLabel: l10n.captureTypeExpense,
                          totalLabel: l10n.accountsTotal,
                        ),
                        Expanded(
                          child: monthEvents.isEmpty
                              ? Center(child: Text(l10n.transEmpty))
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 88),
                                  itemCount: days.length,
                                  itemBuilder: (context, i) {
                                    final day = days[i];
                                    final items = groups[day]!;
                                    return _DayGroup(
                                      day: day,
                                      events: items,
                                      accounts: accounts,
                                      categories: categories,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        onPressed: _openCapture,
                        backgroundColor: colors.primary,
                        foregroundColor: colors.primaryForeground,
                        shape: const CircleBorder(),
                        tooltip: l10n.transAdd,
                        child: const Icon(FLucideIcons.plus),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({
    required this.income,
    required this.expense,
    required this.total,
    required this.incomeLabel,
    required this.expenseLabel,
    required this.totalLabel,
  });

  final String income;
  final String expense;
  final String total;
  final String incomeLabel;
  final String expenseLabel;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final labelStyle = context.theme.typography.body.sm.copyWith(
      color: colors.mutedForeground,
    );
    final valueStyle = context.theme.typography.body.md.copyWith(
      fontWeight: FontWeight.w700,
    );
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.border)),
        ),
        child: Row(
          children: [
            _SummaryCell(
              label: incomeLabel,
              value: income,
              valueColor: const Color(0xFF1E88E5),
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
            _SummaryCell(
              label: expenseLabel,
              value: expense,
              valueColor: colors.primary,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
            _SummaryCell(
              label: totalLabel,
              value: total,
              valueColor: colors.foreground,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final Color valueColor;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: labelStyle),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: valueStyle.copyWith(color: valueColor, fontSize: 14),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.day,
    required this.events,
    required this.accounts,
    required this.categories,
  });

  final DateTime day;
  final List<LedgerEvent> events;
  final Map<String, Account> accounts;
  final Map<String, Category> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final label = '${day.day} ${weekdays[day.weekday - 1]}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: colors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            label,
            style: context.theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.mutedForeground,
            ),
          ),
        ),
        for (final event in events)
          _EventTile(
            event: event,
            title: _title(l10n, event),
            subtitle: accounts[event.accountId]?.name ?? event.currencyCode,
            amountColor: _amountColor(colors, event),
          ),
      ],
    );
  }

  String _title(AppLocalizations l10n, LedgerEvent event) {
    if (event.eventType == LedgerEventType.transfer.storageKey) {
      return l10n.captureTypeTransfer;
    }
    final cat = event.categoryId == null ? null : categories[event.categoryId];
    if (cat != null) return cat.name;
    if (event.eventType == LedgerEventType.income.storageKey) {
      return l10n.captureTypeIncome;
    }
    if (event.eventType == LedgerEventType.expense.storageKey) {
      return l10n.captureTypeExpense;
    }
    return event.eventType;
  }

  Color _amountColor(FColors colors, LedgerEvent event) {
    if (event.eventType == LedgerEventType.income.storageKey) {
      return const Color(0xFF1E88E5);
    }
    if (event.eventType == LedgerEventType.expense.storageKey) {
      return colors.primary;
    }
    return colors.foreground;
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.title,
    required this.subtitle,
    required this.amountColor,
  });

  final LedgerEvent event;
  final String title;
  final String subtitle;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final amount = Money(
      minorUnits: event.amountMinor,
      currencyCode: event.currencyCode,
    ).format();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.theme.typography.body.sm.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: context.theme.typography.body.md.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
