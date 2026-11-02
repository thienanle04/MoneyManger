import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/l10n/app_localizations.dart';

import '../../core/money/currencies.dart';
import '../../core/money/money.dart';

const _kCurrencyNavy = Color(0xFF1A2B4A);
const _kCurrencyNavySelected = Color(0xFF2A4068);
const _kCurrencyLine = Color(0xFF3A5078);

/// Result from [AmountKeypadSheet].
class AmountKeypadResult {
  const AmountKeypadResult({
    required this.text,
    required this.currencyCode,
  });

  final String text;
  final String currencyCode;
}

/// Money Lover–style amount keypad (grid only — amount shows on the form above).
class AmountKeypadSheet extends StatefulWidget {
  const AmountKeypadSheet({
    required this.initialText,
    required this.currencyCode,
    this.lockCurrency = false,
    this.onChanged,
    this.onDone,
    this.onClose,
    super.key,
  });

  final String initialText;
  final String currencyCode;

  /// When true, currency quick-picks are disabled (account currency is fixed).
  final bool lockCurrency;

  /// Fired on every edit so the Capture form amount row updates live.
  final void Function(String text, String currencyCode)? onChanged;

  /// When set, Done uses this instead of [Navigator.pop] (inline panel mode).
  final void Function(AmountKeypadResult result)? onDone;

  /// When set, close (X) uses this instead of [Navigator.pop].
  final VoidCallback? onClose;

  @override
  State<AmountKeypadSheet> createState() => _AmountKeypadSheetState();
}

class _AmountKeypadSheetState extends State<AmountKeypadSheet> {
  late String _text;
  late String _currencyCode;

  static const _quickCodes = ['VND', 'USD', 'EUR', 'GBP', 'THB', 'AUD'];

  @override
  void initState() {
    super.initState();
    _text = widget.initialText;
    _currencyCode = widget.currencyCode;
  }

  void _notify() {
    widget.onChanged?.call(_doneText(), _currencyCode);
  }

  void _setText(String value) {
    setState(() => _text = value);
    _notify();
  }

  void _append(String chunk) {
    var next = _text;
    if (next == '0' && chunk != '00' && chunk != '000') {
      next = chunk;
    } else {
      next += chunk;
    }
    _setText(next);
  }

  void _backspace() {
    if (_text.isEmpty) return;
    _setText(_text.substring(0, _text.length - 1));
  }

  void _toggleMinus() {
    if (_text.startsWith('-')) {
      _setText(_text.substring(1));
    } else if (_text.isNotEmpty) {
      _setText('-$_text');
    } else {
      _setText('-');
    }
  }

  Future<void> _openCalculator() async {
    final result = await showFSheet<String>(
      context: context,
      side: .btt,
      mainAxisMaxRatio: 0.7,
      style: const FModalSheetStyle(),
      builder: (ctx) => _AdvancedCalculatorSheet(
        initialText: _text.startsWith('-') ? _text.substring(1) : _text,
        currencyCode: _currencyCode,
      ),
    );
    if (result != null && mounted) {
      _setText(result);
    }
  }

  String _doneText() {
    if (_text.startsWith('-')) return _text.substring(1);
    return _text;
  }

  void _done() {
    final result = AmountKeypadResult(
      text: _doneText(),
      currencyCode: _currencyCode,
    );
    if (widget.onDone != null) {
      widget.onDone!(result);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  void _close() {
    final result = AmountKeypadResult(
      text: _doneText(),
      currencyCode: _currencyCode,
    );
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    // Explicit grey — theme `border` can be nearly invisible on white.
    const line = Color(0xFFD0D0D0);

    final rows = <List<Widget>>[
      [
        _GridKey(label: '1', onPress: () => _append('1')),
        _GridKey(label: '2', onPress: () => _append('2')),
        _GridKey(label: '3', onPress: () => _append('3')),
        _GridKey(icon: FLucideIcons.delete, onPress: _backspace),
      ],
      [
        _GridKey(label: '4', onPress: () => _append('4')),
        _GridKey(label: '5', onPress: () => _append('5')),
        _GridKey(label: '6', onPress: () => _append('6')),
        _GridKey(icon: FLucideIcons.minus, onPress: _toggleMinus),
      ],
      [
        _GridKey(label: '7', onPress: () => _append('7')),
        _GridKey(label: '8', onPress: () => _append('8')),
        _GridKey(label: '9', onPress: () => _append('9')),
        _GridKey(icon: FLucideIcons.calculator, onPress: _openCalculator),
      ],
      [
        _GridKey(label: '00', onPress: () => _append('00')),
        _GridKey(label: '0', onPress: () => _append('0')),
        _GridKey(label: '000', onPress: () => _append('000')),
        _GridKey(
          label: l10n.captureDone,
          onPress: _done,
          filled: true,
          fillColor: colors.primary,
          foregroundColor: colors.primaryForeground,
        ),
      ],
    ];

    final currencyCells = [
      for (final code in _quickCodes)
        _CurrencyGridCell(
          symbol: Currencies.resolve(code).symbol,
          selected: _currencyCode == code,
          enabled: !widget.lockCurrency,
          onPress: () {
            setState(() => _currencyCode = code);
            _notify();
          },
        ),
    ];

    return Material(
      color: colors.background,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              color: colors.secondaryForeground,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.captureAmount,
                      style: context.theme.typography.body.md.copyWith(
                        color: colors.background,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _close,
                    child: Icon(FLucideIcons.x, color: colors.background),
                  ),
                ],
              ),
            ),
            ColoredBox(
              color: _kCurrencyNavy,
              child: _KeypadGrid(
                lineColor: _kCurrencyLine,
                rows: [currencyCells],
              ),
            ),
            _KeypadGrid(lineColor: line, rows: rows),
          ],
        ),
      ),
    );
  }
}

class _CurrencyGridCell extends StatelessWidget {
  const _CurrencyGridCell({
    required this.symbol,
    required this.selected,
    required this.enabled,
    required this.onPress,
  });

  final String symbol;
  final bool selected;
  final bool enabled;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _kCurrencyNavySelected : _kCurrencyNavy,
      child: InkWell(
        onTap: enabled ? onPress : null,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                color: Colors.white.withValues(alpha: enabled ? 1 : 0.45),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Expression calculator that returns a major-unit amount string.
class _AdvancedCalculatorSheet extends StatefulWidget {
  const _AdvancedCalculatorSheet({
    required this.initialText,
    required this.currencyCode,
  });

  final String initialText;
  final String currencyCode;

  @override
  State<_AdvancedCalculatorSheet> createState() =>
      _AdvancedCalculatorSheetState();
}

class _AdvancedCalculatorSheetState extends State<_AdvancedCalculatorSheet> {
  late String _expression;

  @override
  void initState() {
    super.initState();
    _expression = widget.initialText;
  }

  void _append(String chunk) {
    setState(() {
      if (_expression == '0' && RegExp(r'^\d$').hasMatch(chunk)) {
        _expression = chunk;
      } else {
        _expression += chunk;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_expression.isEmpty) return;
      _expression = _expression.substring(0, _expression.length - 1);
    });
  }

  void _clear() => setState(() => _expression = '');

  void _equals() {
    final value = _evaluate(_expression);
    if (value == null) return;
    setState(() {
      if (value == value.roundToDouble()) {
        _expression = value.round().toString();
      } else {
        _expression =
            value.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
      }
    });
  }

  void _useResult() {
    final value = _evaluate(_expression) ?? double.tryParse(_expression);
    if (value == null) return;
    final abs = value.abs();
    final currency = Currencies.resolve(widget.currencyCode);
    final text = currency.decimalDigits == 0
        ? abs.round().toString()
        : abs.toStringAsFixed(currency.decimalDigits);
    Navigator.of(context).pop(text);
  }

  static double? _evaluate(String raw) {
    final input = raw.replaceAll(' ', '');
    if (input.isEmpty) return null;
    final tokens = RegExp(r'(\d+\.?\d*|[+\-*/])')
        .allMatches(input)
        .map((m) => m.group(0)!)
        .toList();
    if (tokens.isEmpty) return null;

    double? acc;
    String? op;
    for (final token in tokens) {
      if (token == '+' || token == '-' || token == '*' || token == '/') {
        op = token;
        continue;
      }
      final n = double.tryParse(token);
      if (n == null) return null;
      if (acc == null) {
        acc = n;
      } else if (op != null) {
        switch (op) {
          case '+':
            acc = acc + n;
          case '-':
            acc = acc - n;
          case '*':
            acc = acc * n;
          case '/':
            if (n == 0) return null;
            acc = acc / n;
        }
        op = null;
      } else {
        return null;
      }
    }
    return acc;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    const line = Color(0xFFD0D0D0);
    final preview = Money.formatMajorInput(
      _expression.isEmpty
          ? '0'
          : (_evaluate(_expression)?.abs().toString() ?? '0'),
      currencyCode: widget.currencyCode,
    );

    final rows = <List<Widget>>[
      [
        _GridKey(label: 'C', onPress: _clear),
        _GridKey(icon: FLucideIcons.delete, onPress: _backspace),
        _GridKey(label: '/', onPress: () => _append('/')),
        _GridKey(label: '*', onPress: () => _append('*')),
      ],
      [
        _GridKey(label: '7', onPress: () => _append('7')),
        _GridKey(label: '8', onPress: () => _append('8')),
        _GridKey(label: '9', onPress: () => _append('9')),
        _GridKey(label: '-', onPress: () => _append('-')),
      ],
      [
        _GridKey(label: '4', onPress: () => _append('4')),
        _GridKey(label: '5', onPress: () => _append('5')),
        _GridKey(label: '6', onPress: () => _append('6')),
        _GridKey(label: '+', onPress: () => _append('+')),
      ],
      [
        _GridKey(label: '1', onPress: () => _append('1')),
        _GridKey(label: '2', onPress: () => _append('2')),
        _GridKey(label: '3', onPress: () => _append('3')),
        _GridKey(label: '.', onPress: () => _append('.')),
      ],
      [
        _GridKey(label: '0', onPress: () => _append('0')),
        _GridKey(label: '00', onPress: () => _append('00')),
        _GridKey(icon: FLucideIcons.equal, onPress: _equals),
        _GridKey(
          label: l10n.captureDone,
          onPress: _useResult,
          filled: true,
          fillColor: colors.primary,
          foregroundColor: colors.primaryForeground,
        ),
      ],
    ];

    return Material(
      color: colors.background,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: colors.secondaryForeground,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.captureCalculator,
                      style: context.theme.typography.body.md.copyWith(
                        color: colors.background,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(FLucideIcons.x, color: colors.background),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _expression.isEmpty ? '0' : _expression,
                    textAlign: TextAlign.right,
                    style: context.theme.typography.body.lg,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    textAlign: TextAlign.right,
                    style: context.theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _KeypadGrid(lineColor: line, rows: rows),
          ],
        ),
      ),
    );
  }
}

/// Flat ruled grid. Borders use [foregroundDecoration] so opaque key fills
/// cannot paint over the lines.
class _KeypadGrid extends StatelessWidget {
  const _KeypadGrid({
    required this.rows,
    required this.lineColor,
  });

  final List<List<Widget>> rows;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: lineColor, width: 1);
    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border(top: side, left: side),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in rows)
            Row(
              children: [
                for (final cell in row)
                  Expanded(
                    child: Container(
                      foregroundDecoration: BoxDecoration(
                        border: Border(right: side, bottom: side),
                      ),
                      child: cell,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _GridKey extends StatelessWidget {
  const _GridKey({
    required this.onPress,
    this.label,
    this.icon,
    this.filled = false,
    this.fillColor,
    this.foregroundColor,
  });

  final VoidCallback onPress;
  final String? label;
  final IconData? icon;
  final bool filled;
  final Color? fillColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final fg = foregroundColor ?? colors.foreground;
    return Material(
      color: filled ? (fillColor ?? colors.primary) : colors.background,
      child: InkWell(
        onTap: onPress,
        child: SizedBox(
          height: _keyHeight,
          child: Center(
            child: icon != null
                ? Icon(icon, color: fg, size: 22)
                : Text(
                    label!,
                    style: context.theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

const _keyHeight = 56.0;
