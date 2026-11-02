import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../core/money/currencies.dart';
import '../../core/money/money.dart';
import '../../data/ledger/transfer_payload.dart';
import '../../data/providers/database_provider.dart';
import '../../domain/enums/ledger_event_type.dart';
import '../accounts/account_form_screen.dart';
import 'amount_keypad_sheet.dart';
import 'capture_providers.dart';

enum CaptureKind { expense, income, transfer }

/// Opens [CaptureScreen] sliding up from the bottom, amount keypad ready.
Future<T?> showCaptureSheet<T>(BuildContext context) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 520),
      reverseTransitionDuration: const Duration(milliseconds: 480),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const CaptureScreen(openAmountOnStart: true);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    ),
  );
}

enum _CaptureField {
  date,
  amount,
  category,
  account,
  fromAccount,
  toAccount,
  note,
  description,
}

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({
    super.key,
    this.openAmountOnStart = false,
  });

  /// When true, opens the amount keypad after accounts load.
  final bool openAmountOnStart;

  @override
  ConsumerState<CaptureScreen> createState() => CaptureScreenState();
}

class CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _noteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _formScroll = ScrollController();
  final _uuid = const Uuid();
  final _fieldKeys = {
    for (final field in _CaptureField.values) field: GlobalKey(),
  };

  CaptureKind _kind = CaptureKind.expense;
  String _amountText = '';
  String? _amountCurrencyCode;
  String? _accountId;
  String? _destAccountId;
  String? _categoryId;
  DateTime _occurredAt = DateTime.now();
  var _saving = false;
  String? _fieldError;
  _CaptureField? _activeField;
  var _amountPanelSession = 0;
  String _keypadCurrencyCode = 'VND';
  var _keypadLockCurrency = false;
  var _didAutoOpenAmount = false;

  CaptureKind get kind => _kind;

  Color _kindAccent(FColors colors, [CaptureKind? kind]) => switch (kind ?? _kind) {
        CaptureKind.income => const Color(0xFF1E88E5),
        CaptureKind.expense => colors.primary,
        CaptureKind.transfer => colors.foreground,
      };

  Future<void> _switchKind(
    CaptureKind next, {
    required String amountCurrency,
    required bool lockCurrency,
    required List<Category> categories,
    required List<Account> accounts,
  }) async {
    if (next == _kind) return;

    final panel = _activeField;
    final flash = _editorPanelOpen;

    setState(() {
      _categoryId = null;
      _kind = next;
      _fieldError = null;
      if (flash) {
        _activeField = null;
      }
    });

    if (!flash || panel == null) return;

    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted || _kind != next) return;

    final reopen = switch (panel) {
      _CaptureField.amount => _CaptureField.amount,
      _CaptureField.category =>
        next == CaptureKind.transfer ? null : _CaptureField.category,
      _CaptureField.account => next == CaptureKind.transfer
          ? _CaptureField.fromAccount
          : _CaptureField.account,
      _CaptureField.fromAccount || _CaptureField.toAccount =>
        next == CaptureKind.transfer ? panel : _CaptureField.account,
      _ => null,
    };
    if (reopen == null) return;

    switch (reopen) {
      case _CaptureField.amount:
        _openAmountKeypad(
          currencyCode: amountCurrency,
          lockCurrency: lockCurrency,
        );
      case _CaptureField.category:
        _openCategoryPicker(categories);
      case _CaptureField.account:
      case _CaptureField.fromAccount:
        _openAccountPicker(accounts: accounts, dest: false);
      case _CaptureField.toAccount:
        _openAccountPicker(accounts: accounts, dest: true);
      case _CaptureField.date:
      case _CaptureField.note:
      case _CaptureField.description:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _noteFocus.addListener(_onNoteFocusChange);
    _descriptionFocus.addListener(_onDescriptionFocusChange);
  }

  void _onNoteFocusChange() {
    setState(() {
      if (_noteFocus.hasFocus) {
        _activeField = _CaptureField.note;
        _scrollToField(_CaptureField.note);
      } else if (_activeField == _CaptureField.note) {
        _activeField = null;
      }
    });
  }

  void _onDescriptionFocusChange() {
    setState(() {
      if (_descriptionFocus.hasFocus) {
        _activeField = _CaptureField.description;
        _scrollToField(_CaptureField.description);
      } else if (_activeField == _CaptureField.description) {
        _activeField = null;
      }
    });
  }

  void _scrollToField(_CaptureField field) {
    // Amount/date sit at the top — pin scroll to 0 so following rows
    // (category, account, …) and their underlines stay visible above the keypad.
    if (field == _CaptureField.date || field == _CaptureField.amount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_formScroll.hasClients) return;
        _formScroll.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      });
      return;
    }

    void ensure() {
      if (!mounted) return;
      final ctx = _fieldKeys[field]?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: 0.15,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ensure();
      WidgetsBinding.instance.addPostFrameCallback((_) => ensure());
    });
  }

  bool get _editorPanelOpen => switch (_activeField) {
        _CaptureField.amount ||
        _CaptureField.category ||
        _CaptureField.account ||
        _CaptureField.fromAccount ||
        _CaptureField.toAccount =>
          true,
        _ => false,
      };

  void _activateEditor(_CaptureField field) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _activeField = field);
    _scrollToField(field);
  }

  void _closeEditor() {
    if (!mounted) return;
    setState(() {
      if (_editorPanelOpen) {
        _activeField = null;
      }
    });
  }

  @override
  void dispose() {
    _noteFocus.removeListener(_onNoteFocusChange);
    _descriptionFocus.removeListener(_onDescriptionFocusChange);
    _noteFocus.dispose();
    _descriptionFocus.dispose();
    _formScroll.dispose();
    _noteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _majorInputText(int amountMinor, String currencyCode) {
    final currency = Currencies.resolve(currencyCode);
    final major = amountMinor / currency.minorUnitsPerMajor;
    if (currency.decimalDigits == 0) {
      return major.round().toString();
    }
    return major.toStringAsFixed(currency.decimalDigits);
  }

  void applyRepeat(LedgerEvent event) {
    final kind = event.eventType == LedgerEventType.income.storageKey
        ? CaptureKind.income
        : CaptureKind.expense;
    setState(() {
      _kind = kind;
      _accountId = event.accountId;
      _categoryId = event.categoryId;
      _amountText = _majorInputText(event.amountMinor, event.currencyCode);
      _fieldError = null;
    });
  }

  Future<void> _pickOccurredAt() async {
    _activateEditor(_CaptureField.date);
    try {
      final date = await showDatePicker(
        context: context,
        initialDate: _occurredAt,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (date == null || !mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_occurredAt),
      );
      if (!mounted) return;
      setState(() {
        _occurredAt = DateTime(
          date.year,
          date.month,
          date.day,
          time?.hour ?? _occurredAt.hour,
          time?.minute ?? _occurredAt.minute,
        );
      });
    } finally {
      if (mounted && _activeField == _CaptureField.date) {
        setState(() => _activeField = null);
      }
    }
  }

  String _formatOccurredAt() {
    final d = _occurredAt;
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final wd = weekdays[d.weekday - 1];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day}/${d.year % 100} ($wd) $hh:$mm';
  }

  void _openAmountKeypad({
    required String currencyCode,
    required bool lockCurrency,
  }) {
    setState(() {
      _keypadCurrencyCode = currencyCode;
      _keypadLockCurrency = lockCurrency;
      _amountPanelSession++;
    });
    _activateEditor(_CaptureField.amount);
  }

  void _openCategoryPicker(List<Category> categories) {
    final l10n = AppLocalizations.of(context)!;
    if (categories.isEmpty) {
      setState(() => _fieldError = l10n.captureNoCategories);
      return;
    }
    _activateEditor(_CaptureField.category);
  }

  void _openAccountPicker({
    required List<Account> accounts,
    required bool dest,
  }) {
    final field = dest
        ? _CaptureField.toAccount
        : (_kind == CaptureKind.transfer
            ? _CaptureField.fromAccount
            : _CaptureField.account);
    _activateEditor(field);
  }

  Future<bool> _save(
    List<Account> accounts, {
    required bool clearAfter,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    Account? account;
    for (final a in accounts) {
      if (a.id == _accountId) {
        account = a;
        break;
      }
    }

    if (account == null) {
      setState(() => _fieldError = l10n.captureSelectAccount);
      return false;
    }

    final money = Money.parse(
      _amountText,
      currencyCode: account.currencyCode,
    );
    if (money == null || money.minorUnits <= 0) {
      setState(() => _fieldError = l10n.captureInvalidAmount);
      return false;
    }

    if (_kind != CaptureKind.transfer) {
      if (_categoryId == null) {
        setState(() => _fieldError = l10n.captureSelectCategory);
        return false;
      }
    } else {
      if (_destAccountId == null) {
        setState(() => _fieldError = l10n.captureSelectDestAccount);
        return false;
      }
      if (_destAccountId == account.id) {
        setState(() => _fieldError = l10n.captureSameAccount);
        return false;
      }
      Account? dest;
      for (final a in accounts) {
        if (a.id == _destAccountId) {
          dest = a;
          break;
        }
      }
      if (dest == null) {
        setState(() => _fieldError = l10n.captureSelectDestAccount);
        return false;
      }
      if (dest.currencyCode != account.currencyCode) {
        setState(() => _fieldError = l10n.captureCrossCurrencyBlocked);
        return false;
      }
    }

    setState(() {
      _saving = true;
      _fieldError = null;
    });

    final clientRequestId = _uuid.v4();
    final note = _noteController.text.trim();
    final description = _descriptionController.text.trim();
    final writer = ref.read(ledgerWriterProvider);

    try {
      switch (_kind) {
        case CaptureKind.expense:
          await writer.append(
            type: LedgerEventType.expense,
            occurredAt: _occurredAt,
            currencyCode: account.currencyCode,
            amountMinor: money.minorUnits,
            accountId: account.id,
            categoryId: _categoryId,
            payloadJson: encodeNotePayload(note, description: description),
            clientRequestId: clientRequestId,
          );
        case CaptureKind.income:
          await writer.append(
            type: LedgerEventType.income,
            occurredAt: _occurredAt,
            currencyCode: account.currencyCode,
            amountMinor: money.minorUnits,
            accountId: account.id,
            categoryId: _categoryId,
            payloadJson: encodeNotePayload(note, description: description),
            clientRequestId: clientRequestId,
          );
        case CaptureKind.transfer:
          await writer.append(
            type: LedgerEventType.transfer,
            occurredAt: _occurredAt,
            currencyCode: account.currencyCode,
            amountMinor: money.minorUnits,
            accountId: account.id,
            transfer: TransferPayload(
              destAccountId: _destAccountId!,
              sourceAmountMinor: money.minorUnits,
              destAmountMinor: money.minorUnits,
              sourceCurrency: account.currencyCode,
              destCurrency: account.currencyCode,
              note: note.isEmpty ? null : note,
            ),
            clientRequestId: clientRequestId,
          );
      }

      if (!mounted) return false;
      final formatted = money.format();
      setState(() {
        _saving = false;
        if (clearAfter) {
          _amountText = '';
          _noteController.clear();
          _descriptionController.clear();
        }
      });
      showFToast(
        context: context,
        title: Text(l10n.captureSaved(formatted)),
      );
      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _saving = false;
        _fieldError = l10n.captureError;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountsAsync = ref.watch(accountsProvider);
    // Watch all categories once. Filtering by kind client-side avoids a family
    // provider remount (AsyncLoading → full-screen spinner flash) on first
    // Income/Expense/Transfer switch.
    final categoriesAsync = ref.watch(categoriesProvider(null));
    final isIncome = _kind == CaptureKind.income;
    final colors = context.theme.colors;

    ref.listen<int>(captureRepeatTriggerProvider, (prev, next) {
      if (prev == next) return;
      final events = ref.read(recentEventsProvider).asData?.value;
      if (events == null) return;
      for (final e in events) {
        if (e.eventType == LedgerEventType.expense.storageKey ||
            e.eventType == LedgerEventType.income.storageKey) {
          applyRepeat(e);
          break;
        }
      }
    });

    return accountsAsync.when(
      loading: () => const Center(child: FCircularProgress()),
      error: (e, _) => Center(child: Text('$e')),
      data: (accounts) {
        if (accounts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.captureNoAccountsTitle,
                    style: context.theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.captureNoAccountsBody),
                  const SizedBox(height: 16),
                  FButton(
                    onPress: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AccountFormScreen(),
                      ),
                    ),
                    child: Text(l10n.captureCreateAccount),
                  ),
                ],
              ),
            ),
          );
        }

        return categoriesAsync.when(
          skipLoadingOnReload: true,
          loading: () => const Center(child: FCircularProgress()),
          error: (e, _) => Center(child: Text('$e')),
          data: (categories) {
            Account? account;
            for (final a in accounts) {
              if (a.id == _accountId) {
                account = a;
                break;
              }
            }
            final filteredCategories = _kind == CaptureKind.transfer
                ? const <Category>[]
                : categories.where((c) => c.isIncome == isIncome).toList();
            String? categoryName;
            for (final c in filteredCategories) {
              if (c.id == _categoryId) {
                categoryName = c.name;
                break;
              }
            }
            String? destName;
            for (final a in accounts) {
              if (a.id == _destAccountId) {
                destName = a.name;
                break;
              }
            }
            final amountCurrency = account?.currencyCode ??
                _amountCurrencyCode ??
                ref.watch(baseCurrencyProvider).asData?.value ??
                Currencies.defaultBase;
            final amountDisplay = _amountText.isEmpty
                ? ''
                : Money.formatMajorInput(
                    _amountText,
                    currencyCode: amountCurrency,
                  );
            final accent = _kindAccent(colors);
            final kindTitle = switch (_kind) {
              CaptureKind.income => l10n.captureTypeIncome,
              CaptureKind.expense => l10n.captureTypeExpense,
              CaptureKind.transfer => l10n.captureTypeTransfer,
            };

            if (widget.openAmountOnStart &&
                !_didAutoOpenAmount &&
                accounts.isNotEmpty) {
              _didAutoOpenAmount = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _openAmountKeypad(
                  currencyCode: amountCurrency,
                  lockCurrency: account != null,
                );
              });
            }

            return Material(
              color: colors.background,
              child: Column(
                children: [
                  ColoredBox(
                    color: colors.primary,
                    child: SafeArea(
                      bottom: false,
                      child: SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  Navigator.of(context).maybePop(),
                              icon: Icon(
                                FLucideIcons.arrowLeft,
                                color: colors.primaryForeground,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                kindTitle,
                                style:
                                    context.theme.typography.body.lg.copyWith(
                                  color: colors.primaryForeground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                ref
                                    .read(
                                      captureRepeatTriggerProvider.notifier,
                                    )
                                    .state++;
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
                    child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Row(
                    children: [
                      for (final entry in [
                        (CaptureKind.income, l10n.captureTypeIncome),
                        (CaptureKind.expense, l10n.captureTypeExpense),
                        (CaptureKind.transfer, l10n.captureTypeTransfer),
                      ])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Builder(
                              builder: (context) {
                                final selected = _kind == entry.$1;
                                final tabAccent = _kindAccent(colors, entry.$1);
                                return OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: selected
                                        ? tabAccent
                                        : colors.mutedForeground,
                                    side: BorderSide(
                                      color:
                                          selected ? tabAccent : colors.border,
                                      width: selected ? 1.5 : 1,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () => _switchKind(
                                    entry.$1,
                                    amountCurrency: amountCurrency,
                                    lockCurrency: account != null,
                                    categories: filteredCategories,
                                    accounts: accounts,
                                  ),
                                  child: Text(entry.$2),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _formScroll,
                    padding: EdgeInsets.only(
                      bottom: switch (_activeField) {
                        _CaptureField.note ||
                        _CaptureField.description =>
                          280,
                        _ => 8,
                      },
                    ),
                    children: [
                      KeyedSubtree(
                        key: _fieldKeys[_CaptureField.date],
                        child: _FormRow(
                          label: l10n.captureDate,
                          value: _formatOccurredAt(),
                          accent: accent,
                          active: _activeField == _CaptureField.date,
                          onTap: _pickOccurredAt,
                        ),
                      ),
                      KeyedSubtree(
                        key: _fieldKeys[_CaptureField.amount],
                        child: _FormRow(
                          label: l10n.captureAmount,
                          value: amountDisplay,
                          accent: accent,
                          emphasized: true,
                          active: _activeField == _CaptureField.amount,
                          onTap: () => _openAmountKeypad(
                            currencyCode: amountCurrency,
                            lockCurrency: account != null,
                          ),
                        ),
                      ),
                      if (_kind != CaptureKind.transfer)
                        KeyedSubtree(
                          key: _fieldKeys[_CaptureField.category],
                          child: _FormRow(
                            label: l10n.captureCategory,
                            value: categoryName ?? '',
                            accent: accent,
                            active: _activeField == _CaptureField.category,
                            onTap: () =>
                                _openCategoryPicker(filteredCategories),
                          ),
                        ),
                      if (_kind == CaptureKind.transfer) ...[
                        KeyedSubtree(
                          key: _fieldKeys[_CaptureField.fromAccount],
                          child: _FormRow(
                            label: l10n.captureFromAccount,
                            value: account?.name ?? '',
                            accent: accent,
                            active:
                                _activeField == _CaptureField.fromAccount,
                            onTap: () => _openAccountPicker(
                              accounts: accounts,
                              dest: false,
                            ),
                          ),
                        ),
                        KeyedSubtree(
                          key: _fieldKeys[_CaptureField.toAccount],
                          child: _FormRow(
                            label: l10n.captureToAccount,
                            value: destName ?? '',
                            accent: accent,
                            active: _activeField == _CaptureField.toAccount,
                            onTap: () => _openAccountPicker(
                              accounts: accounts,
                              dest: true,
                            ),
                          ),
                        ),
                      ] else
                        KeyedSubtree(
                          key: _fieldKeys[_CaptureField.account],
                          child: _FormRow(
                            label: l10n.captureAccount,
                            value: account?.name ?? '',
                            accent: accent,
                            active: _activeField == _CaptureField.account,
                            onTap: () => _openAccountPicker(
                              accounts: accounts,
                              dest: false,
                            ),
                          ),
                        ),
                      KeyedSubtree(
                        key: _fieldKeys[_CaptureField.note],
                        child: _FormRow(
                          label: l10n.captureNote,
                          accent: accent,
                          active: _activeField == _CaptureField.note,
                          child: TextField(
                            controller: _noteController,
                            focusNode: _noteFocus,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      KeyedSubtree(
                        key: _fieldKeys[_CaptureField.description],
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: TextField(
                            controller: _descriptionController,
                            focusNode: _descriptionFocus,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: l10n.captureDescription,
                              suffixIcon: Icon(
                                FLucideIcons.camera,
                                color: colors.mutedForeground,
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      _activeField == _CaptureField.description
                                          ? accent
                                          : const Color(0xFFD0D0D0),
                                  width: _activeField ==
                                          _CaptureField.description
                                      ? 1.5
                                      : 1,
                                ),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFD0D0D0),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_fieldError != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            _fieldError!,
                            style: TextStyle(color: colors.destructive),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_activeField == _CaptureField.amount)
                  AmountKeypadSheet(
                    key: ValueKey(
                      '$_amountPanelSession-${_kind.name}-$accent',
                    ),
                    initialText: _amountText,
                    currencyCode: _keypadCurrencyCode,
                    lockCurrency: _keypadLockCurrency,
                    onChanged: (text, code) {
                      setState(() {
                        _amountText = text;
                        if (!_keypadLockCurrency) {
                          _amountCurrencyCode = code;
                        }
                        _fieldError = null;
                      });
                    },
                    onDone: (result) {
                      setState(() {
                        _amountText = result.text;
                        if (!_keypadLockCurrency) {
                          _amountCurrencyCode = result.currencyCode;
                        }
                        _fieldError = null;
                        _activeField = null;
                      });
                    },
                    onClose: _closeEditor,
                  )
                else if (_activeField == _CaptureField.category)
                  _InlinePickerScaffold(
                    title: l10n.captureCategory,
                    heightFactor: 0.42,
                    onClose: _closeEditor,
                    child: ListView.separated(
                      itemCount: filteredCategories.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: colors.border,
                      ),
                      itemBuilder: (_, i) {
                        final c = filteredCategories[i];
                        final selected = c.id == _categoryId;
                        return ListTile(
                          title: Text(c.name),
                          trailing: selected
                              ? Icon(FLucideIcons.check, color: accent)
                              : const Icon(FLucideIcons.chevronRight),
                          onTap: () {
                            setState(() {
                              _categoryId = c.id;
                              _fieldError = null;
                              _activeField = null;
                            });
                          },
                        );
                      },
                    ),
                  )
                else if (_activeField == _CaptureField.account ||
                    _activeField == _CaptureField.fromAccount ||
                    _activeField == _CaptureField.toAccount)
                  _InlinePickerScaffold(
                    title: _activeField == _CaptureField.toAccount
                        ? l10n.captureToAccount
                        : l10n.captureAccount,
                    heightFactor: 0.42,
                    onClose: _closeEditor,
                    trailing: IconButton(
                      icon: const Icon(FLucideIcons.pencil, color: Colors.white),
                      onPressed: () {
                        _closeEditor();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AccountFormScreen(),
                          ),
                        );
                      },
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: accounts.length,
                      itemBuilder: (_, i) {
                        final a = accounts[i];
                        final current = _activeField == _CaptureField.toAccount
                            ? _destAccountId
                            : _accountId;
                        final isSelected = a.id == current;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_activeField == _CaptureField.toAccount) {
                                _destAccountId = a.id;
                              } else {
                                _accountId = a.id;
                              }
                              _fieldError = null;
                              _activeField = null;
                            });
                          },
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? accent
                                    : colors.border,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected
                                  ? accent.withValues(alpha: 0.08)
                                  : colors.background,
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  a.name,
                                  textAlign: TextAlign.center,
                                  style: context.theme.typography.body.sm
                                      .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? accent
                                        : colors.foreground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  SafeArea(
                    top: false,
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: FButton(
                              onPress: _saving
                                  ? null
                                  : () => _save(accounts, clearAfter: true),
                              child: Text(
                                _saving
                                    ? l10n.captureSaving
                                    : l10n.captureSave,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FButton(
                              variant: .outline,
                              onPress: _saving
                                  ? null
                                  : () =>
                                      _save(accounts, clearAfter: false),
                              child: Text(l10n.captureContinue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.onClose,
    this.trailing,
  });

  final String title;
  final VoidCallback onClose;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      color: colors.secondaryForeground,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.theme.typography.body.md.copyWith(
                color: colors.background,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?trailing,
          IconButton(
            onPressed: onClose,
            icon: Icon(FLucideIcons.x, color: colors.background),
          ),
        ],
      ),
    );
  }
}

class _InlinePickerScaffold extends StatelessWidget {
  const _InlinePickerScaffold({
    required this.title,
    required this.onClose,
    required this.child,
    this.trailing,
    this.heightFactor = 0.42,
  });

  final String title;
  final VoidCallback onClose;
  final Widget child;
  final Widget? trailing;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final height = MediaQuery.sizeOf(context).height * heightFactor;
    return Material(
      color: colors.background,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Column(
          children: [
            _SheetHeader(title: title, onClose: onClose, trailing: trailing),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({
    required this.label,
    this.value,
    this.onTap,
    this.child,
    this.emphasized = false,
    this.active = false,
    this.accent,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? child;
  final bool emphasized;
  final bool active;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final display = value ?? '';
    final isEmpty = display.isEmpty;
    final activeColor = accent ?? colors.primary;
    final underline = active ? activeColor : const Color(0xFFD0D0D0);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 88,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  label,
                  style: context.theme.typography.body.md.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 10),
                foregroundDecoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: underline,
                      width: active ? 1.5 : 1,
                    ),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 22),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: child ??
                        Text(
                          display,
                          style: context.theme.typography.body.md.copyWith(
                            color: isEmpty
                                ? colors.mutedForeground
                                : emphasized
                                    ? activeColor
                                    : colors.foreground,
                            fontWeight: emphasized
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
