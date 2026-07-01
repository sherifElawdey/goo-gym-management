import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/locale_number_parser.dart';
import 'package:gym_pro_manager/core/widgets/gradient_button.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:intl/intl.dart' hide TextDirection;

class EditSubscriptionResult {
  const EditSubscriptionResult({
    required this.startDate,
    required this.endDate,
    required this.amount,
  });

  final DateTime startDate;
  final DateTime endDate;
  final double amount;
}

class EditSubscriptionSheet extends StatefulWidget {
  const EditSubscriptionSheet({super.key, required this.subscription});

  final Subscription subscription;

  @override
  State<EditSubscriptionSheet> createState() => _EditSubscriptionSheetState();
}

class _EditSubscriptionSheetState extends State<EditSubscriptionSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _startDate = _dayKey(widget.subscription.startDate);
    _endDate = _dayKey(widget.subscription.endDate);
    _amountController = TextEditingController(
      text: widget.subscription.amount.toStringAsFixed(0),
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

  void _submit() {
    final amount = parseLocalizedDouble(_amountController.text);
    if (!_isValid || amount == null) return;
    Navigator.pop(
      context,
      EditSubscriptionResult(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: l10n.subscriptionStartDate,
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
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        InputDecorator(
          decoration: InputDecoration(
            labelText: l10n.subscriptionEndDate,
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
        if (_endDate.isBefore(_startDate)) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.endDateBeforeStart,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        GradientButton(
          label: l10n.saveChanges,
          icon: Icons.check_rounded,
          onPressed: _isValid ? _submit : null,
        ),
      ],
    );
  }
}
