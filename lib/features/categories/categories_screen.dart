import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

import '../../data/providers/database_provider.dart';
import 'category_form_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoriesProvider(null));

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.settingsCategories),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).pop()),
        ],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.plus),
            onPress: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CategoryFormScreen(),
              ),
            ),
          ),
        ],
      ),
      child: categories.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: FButton(
                onPress: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CategoryFormScreen(),
                  ),
                ),
                child: Text(l10n.categoryAdd),
              ),
            );
          }

          return ListView(
            children: [
              FTileGroup(
                children: [
                  for (final category in list)
                    FTile(
                      title: Text(category.name),
                      subtitle: Text(
                        category.isIncome
                            ? l10n.captureTypeIncome
                            : l10n.captureTypeExpense,
                      ),
                      onPress: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              CategoryFormScreen(category: category),
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
