import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

import '../capture/capture_screen.dart';
import '../home/home_screen.dart';
import '../insights/insights_screen.dart';
import '../settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    CaptureScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titles = [
      l10n.navHome,
      l10n.navCapture,
      l10n.navInsights,
      l10n.navMore,
    ];

    return FScaffold(
      header: FHeader(title: Text(titles[_index])),
      footer: FBottomNavigationBar(
        index: _index,
        onChange: (index) => setState(() => _index = index),
        children: [
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.house),
            label: Text(l10n.navHome),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.circlePlus),
            label: Text(l10n.navCapture),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.chartLine),
            label: Text(l10n.navInsights),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.ellipsis),
            label: Text(l10n.navMore),
          ),
        ],
      ),
      child: IndexedStack(
        index: _index,
        children: _screens,
      ),
    );
  }
}
