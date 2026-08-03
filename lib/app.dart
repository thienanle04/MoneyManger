import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/theme.dart';

import 'features/shell/app_shell.dart';

class MoneyManagerApp extends StatelessWidget {
  const MoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: lightTheme.toApproximateMaterialTheme(),
      darkTheme: darkTheme.toApproximateMaterialTheme(),
      builder: (context, child) => FTheme(
        data: Theme.brightnessOf(context) == Brightness.light
            ? lightTheme
            : darkTheme,
        child: FToaster(
          child: FTooltipGroup(child: child!),
        ),
      ),
      home: const AppShell(),
    );
  }
}
