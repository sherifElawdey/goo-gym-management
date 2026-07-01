import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/currency_formatter.dart';
import 'package:gym_pro_manager/core/utils/locale_number_parser.dart';
import 'package:intl/intl.dart' hide TextDirection;

class RenewSubscriptionResult {
  const RenewSubscriptionResult({
    required this.startDate,
    required this.endDate,
    required this.amount,
  });

  final DateTime startDate;
  final DateTime endDate;
  final double amount;
}

class RenewSubscriptionDialog extends StatefulWidget {
  const RenewSubscriptionDialog({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.initialAmount,
  });

  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final double initialAmount;

  static DateTime defaultRenewStartDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime defaultRenewEndDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, now.day);
  }

  static Future<RenewSubscriptionResult?> show(
    BuildContext context, {
    required DateTime initialStartDate,
    required DateTime initialEndDate,
    required double initialAmount,
  }) {
    return showDialog<RenewSubscriptionResult>(
      context: context,
      builder: (ctx) => RenewSubscriptionDialog(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        initialAmount: initialAmount,
      ),
    );
  }

  @override
  State<RenewSubscriptionDialog> createState() => _RenewSubscriptionDialogState();
}

class _RenewSubscriptionDialogState extends State<RenewSubscriptionDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _startDate = _dayKey(widget.initialStartDate);
    _endDate = _dayKey(widget.initialEndDate);
    _amountController = TextEditingController(
      text: widget.initialAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get _isValid {
    final amount = parseLocalizedDouble(_amountController.text);
    return !_endDate.isBefore(_startDate) && amount != null && amount > 0;
  }

  int get _durationDays => _endDate.difference(_startDate).inDays;

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
      locale: const Locale('ar', 'EG'),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _startDate = _dayKey(picked);
      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365 * 3)),
      locale: const Locale('ar', 'EG'),
    );
    if (picked == null || !mounted) return;
    setState(() => _endDate = _dayKey(picked));
  }

  void _confirm() {
    final amount = parseLocalizedDouble(_amountController.text);
    if (!_isValid || amount == null) return;
    Navigator.pop(
      context,
      RenewSubscriptionResult(
        startDate: _startDate,
        endDate: _endDate,
        amount: amount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFmt = DateFormat.yMMMd('ar_EG');
    final amount = parseLocalizedDouble(_amountController.text) ?? 0;

    return AlertDialog(
      title: Text(l10n.renewSubscriptionDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.renewSubscriptionDialogSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.renewSubscriptionStartDate,
                border: const OutlineInputBorder(),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dateFmt.format(_startDate),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: _pickStartDate,
                    icon: const Icon(Icons.calendar_month_rounded),
                    tooltip: l10n.renewSubscriptionStartDate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.renewSubscriptionEndDate,
                border: const OutlineInputBorder(),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dateFmt.format(_endDate),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: _pickEndDate,
                    icon: const Icon(Icons.calendar_month_rounded),
                    tooltip: l10n.pickNewEndDate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _amountController,
              textDirection: TextDirection.ltr,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.subscriptionAmount,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.payments_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.subscriptionSummary(
                CurrencyFormatter.format(amount > 0 ? amount : 0),
                dateFmt.format(_endDate),
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.renewSubscriptionDurationDays(_durationDays),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (_endDate.isBefore(_startDate))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.endDateBeforeStart,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isValid ? _confirm : null,
          child: Text(l10n.renewSubscriptionConfirm),
        ),
      ],
    );
  }
}
