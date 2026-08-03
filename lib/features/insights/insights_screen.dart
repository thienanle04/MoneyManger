import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FCard(
      builder: (context, style, _) => Padding(
        padding: style.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.insightsTitle, style: style.titleTextStyle),
            const SizedBox(height: 8),
            Text(l10n.insightsComingSoon, style: style.subtitleTextStyle),
          ],
        ),
      ),
    );
  }
}
