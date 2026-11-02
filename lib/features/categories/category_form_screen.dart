import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

import '../../data/providers/database_provider.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, this.category});

  final Category? category;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  late final TextEditingController _nameController;
  late bool _isIncome;
  var _saving = false;
  String? _error;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _isIncome = widget.category?.isIncome ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.categoryName);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final repo = ref.read(categoriesRepositoryProvider);
      if (_isEdit) {
        await repo.update(
          id: widget.category!.id,
          name: name,
          isIncome: _isIncome,
        );
      } else {
        await repo.create(name: name, isIncome: _isIncome);
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

    return FScaffold(
      header: FHeader.nested(
        title: Text(_isEdit ? l10n.categoryEdit : l10n.categoryAdd),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).pop()),
        ],
      ),
      child: ListView(
        children: [
          FTextField(
            label: Text(l10n.categoryName),
            control: FTextFieldControl.managed(controller: _nameController),
          ),
          const SizedBox(height: 12),
          FSwitch(
            label: Text(l10n.categoryIsIncome),
            value: _isIncome,
            onChange: (v) => setState(() => _isIncome = v),
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
            child: Text(_saving ? l10n.captureSaving : l10n.categorySave),
          ),
        ],
      ),
    );
  }
}
