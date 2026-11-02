import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

import '../../core/money/currencies.dart';
import '../../core/money/money.dart';
import '../../data/providers/database_provider.dart';

class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({super.key, this.account});

  final Account? account;

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _openingController;
  late String _type;
  late String _currencyCode;
  late bool _includeInNav;
  var _saving = false;
  String? _error;

  bool get _isEdit => widget.account != null;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _nameController = TextEditingController(text: account?.name ?? '');
    _openingController = TextEditingController();
    _type = account?.type ?? 'cash';
    _currencyCode = account?.currencyCode ?? Currencies.defaultBase;
    _includeInNav = account?.includeInNav ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _openingController.dispose();
    super.dispose();
  }

  String _typeLabel(AppLocalizations l10n, String type) => switch (type) {
        'bank' => l10n.accountTypeBank,
        'ewallet' => l10n.accountTypeEwallet,
        _ => l10n.accountTypeCash,
      };

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.accountName);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final repo = ref.read(accountsRepositoryProvider);
      if (_isEdit) {
        await repo.update(
          id: widget.account!.id,
          name: name,
          type: _type,
          includeInNav: _includeInNav,
        );
      } else {
        var opening = 0;
        final openingText = _openingController.text.trim();
        if (openingText.isNotEmpty) {
          final money = Money.parse(
            openingText,
            currencyCode: _currencyCode,
          );
          if (money == null || money.minorUnits <= 0) {
            setState(() {
              _saving = false;
              _error = l10n.captureInvalidAmount;
            });
            return;
          }
          opening = money.minorUnits;
        }
        await repo.create(
          name: name,
          type: _type,
          currencyCode: _currencyCode,
          includeInNav: _includeInNav,
          openingBalanceMinor: opening,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = l10n.captureError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeItems = {
      l10n.accountTypeCash: 'cash',
      l10n.accountTypeBank: 'bank',
      l10n.accountTypeEwallet: 'ewallet',
    };
    final currencyItems = {
      for (final code in Currencies.codes) code: code,
    };

    return FScaffold(
      header: FHeader.nested(
        title: Text(_isEdit ? l10n.accountEdit : l10n.accountAdd),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).pop()),
        ],
      ),
      child: ListView(
        children: [
          FTextField(
            label: Text(l10n.accountName),
            control: FTextFieldControl.managed(controller: _nameController),
          ),
          const SizedBox(height: 12),
          FSelect<String>(
            label: Text(l10n.accountType),
            items: typeItems,
            control: FSelectControl.lifted(
              value: _type,
              onChange: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            hint: _typeLabel(l10n, _type),
          ),
          const SizedBox(height: 12),
          if (!_isEdit) ...[
            FSelect<String>(
              label: Text(l10n.accountCurrency),
              items: currencyItems,
              control: FSelectControl.lifted(
                value: _currencyCode,
                onChange: (v) {
                  if (v != null) setState(() => _currencyCode = v);
                },
              ),
              hint: _currencyCode,
            ),
            const SizedBox(height: 12),
            FTextField(
              label: Text(l10n.accountOpeningBalance),
              control: FTextFieldControl.managed(controller: _openingController),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
          ],
          FSwitch(
            label: Text(l10n.accountIncludeInNav),
            value: _includeInNav,
            onChange: (v) => setState(() => _includeInNav = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: context.theme.colors.destructive),
            ),
          ],
          const SizedBox(height: 24),
          FButton(
            onPress: _saving ? null : _save,
            child: Text(_saving ? l10n.captureSaving : l10n.accountSave),
          ),
        ],
      ),
    );
  }
}
