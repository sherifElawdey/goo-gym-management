import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/constants/app_constants.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/core/utils/currency_formatter.dart';
import 'package:gym_pro_manager/core/utils/locale_number_parser.dart';
import 'package:gym_pro_manager/core/widgets/app_bottom_sheet.dart';
import 'package:gym_pro_manager/core/widgets/app_empty_state.dart';
import 'package:gym_pro_manager/core/widgets/app_error_view.dart';
import 'package:gym_pro_manager/core/widgets/app_loading_view.dart';
import 'package:gym_pro_manager/core/widgets/app_section_header.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/gradient_button.dart';
import 'package:gym_pro_manager/core/widgets/kpi_stat_card.dart';
import 'package:gym_pro_manager/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:intl/intl.dart' hide TextDirection;

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({
    super.key,
    required this.amountsVisible,
    required this.onRevealAmounts,
  });

  final bool amountsVisible;
  final Future<bool> Function() onRevealAmounts;

  static bool _isCurrentMonth(DateTime month) {
    final now = DateTime.now();
    return month.year == now.year && month.month == now.month;
  }

  IconData _categoryIcon(String key) {
    switch (key) {
      case 'rent':
        return Icons.home_work_outlined;
      case 'electricity':
        return Icons.bolt_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'equipment':
        return Icons.fitness_center_outlined;
      case 'maintenance':
        return Icons.build_outlined;
      case 'salaries':
        return Icons.payments_outlined;
      case 'marketing':
        return Icons.campaign_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: l10n.addExpense,
                  icon: Icons.add_rounded,
                  onPressed: () => _showExpenseSheet(context),
                ),
              ),
              if (!amountsVisible) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => onRevealAmounts(),
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(l10n.showFinanceAmounts),
                ),
              ],
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => context.read<FinanceCubit>().refresh(),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: l10n.tryAgain,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<FinanceCubit, FinanceState>(
            builder: (context, state) {
              if (state is FinanceLoadingState) {
                return const AppLoadingView();
              }
              if (state is FinanceErrorState) {
                return AppErrorView(
                  message: state.message,
                  errorTitle: l10n.somethingWentWrong,
                  retryLabel: l10n.tryAgain,
                  onRetry: () => context.read<FinanceCubit>().load(),
                );
              }
              if (state is! FinanceLoadedState) {
                return const SizedBox.shrink();
              }

              final monthLabel = DateFormat.yMMMM('ar_EG').format(state.month);
              final balanceColor =
                  state.currentBalance >= 0 ? AppColors.accentGreen : AppColors.accentRed;
              final dateFmt = DateFormat.yMMMd('ar_EG');

              return RefreshIndicator(
                onRefresh: () => context.read<FinanceCubit>().refresh(),
                child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text(monthLabel),
                          selected: true,
                          onSelected: (_) {},
                        ),
                        if (!_isCurrentMonth(state.month)) ...[
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(l10n.currentMonth),
                            onSelected: (_) {
                              final now = DateTime.now();
                              context.read<FinanceCubit>().load(
                                DateTime(now.year, now.month),
                              );
                            },
                          ),
                        ],
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(l10n.previousMonth),
                          onSelected: (_) {
                            final prev = DateTime(state.month.year, state.month.month - 1);
                            context.read<FinanceCubit>().load(prev);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: w,
                            child: KpiStatCard(
                              label: l10n.revenue,
                              value: CurrencyFormatter.formatSensitive(
                                state.monthlyRevenue,
                                visible: amountsVisible,
                              ),
                              icon: Icons.trending_up_rounded,
                              iconColor: AppColors.accentGreen,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: KpiStatCard(
                              label: l10n.expenses,
                              value: CurrencyFormatter.formatSensitive(
                                state.totalExpenses,
                                visible: amountsVisible,
                              ),
                              icon: Icons.trending_down_rounded,
                              iconColor: AppColors.accentRed,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: KpiStatCard(
                              label: l10n.netProfit,
                              value: CurrencyFormatter.formatSensitive(
                                state.netProfit,
                                visible: amountsVisible,
                              ),
                              icon: Icons.show_chart_rounded,
                              iconColor: AppColors.primary,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: KpiStatCard(
                              label: l10n.balance,
                              value: CurrencyFormatter.formatSensitive(
                                state.currentBalance,
                                visible: amountsVisible,
                              ),
                              icon: Icons.account_balance_wallet_rounded,
                              iconColor: balanceColor,
                              valueColor: balanceColor,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: KpiStatCard(
                              label: l10n.maleIncome,
                              value: CurrencyFormatter.formatSensitive(
                                state.maleRevenue,
                                visible: amountsVisible,
                              ),
                              icon: Icons.male_rounded,
                              iconColor: AppColors.primary,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: KpiStatCard(
                              label: l10n.femaleIncome,
                              value: CurrencyFormatter.formatSensitive(
                                state.femaleRevenue,
                                visible: amountsVisible,
                              ),
                              icon: Icons.female_rounded,
                              iconColor: AppColors.accentRed,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (amountsVisible)
                    GlassCard(
                      child: SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (v) => FlLine(
                                color: AppColors.border,
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) {
                                    final labels = [
                                      l10n.chartRev,
                                      l10n.chartExp,
                                      l10n.chartProfit,
                                      l10n.chartBal,
                                    ];
                                    final i = v.toInt();
                                    if (i < 0 || i >= labels.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Text(
                                      labels[i],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontSize: 11),
                                    );
                                  },
                                ),
                              ),
                              leftTitles:
                                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles:
                                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles:
                                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  FlSpot(0, state.monthlyRevenue),
                                  FlSpot(1, state.totalExpenses),
                                  FlSpot(2, state.netProfit),
                                  FlSpot(3, state.currentBalance),
                                ],
                                isCurved: true,
                                barWidth: 3,
                                color: AppColors.primary,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                ),
                                dotData: const FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    GlassCard(
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                l10n.financeChartHidden,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  AppSectionHeader(
                    title: l10n.expenses,
                    badge: '${state.expenses.length}',
                  ),
                  if (state.expenses.isEmpty)
                    AppEmptyState(
                      title: l10n.noExpensesThisMonth,
                      subtitle: l10n.noExpensesSubtitle,
                      icon: Icons.receipt_long_outlined,
                    )
                  else
                    ...state.expenses.map(
                      (e) {
                        final key = AppConstants.normalizeCategoryKey(e.category);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(_categoryIcon(key), color: AppColors.primary, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.title, style: Theme.of(context).textTheme.titleMedium),
                                      Text(
                                        AppConstants.categoryLabel(l10n, e.category),
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateFmt.format(e.createdAt),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatSensitive(
                                    e.amount,
                                    visible: amountsVisible,
                                  ),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.accentRed,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showExpenseSheet(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<FinanceCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await AppBottomSheet.show<_ExpenseInput>(
      context: context,
      title: l10n.addExpense,
      subtitle: l10n.expenseRecordedMonth,
      child: const _AddExpenseSheetBody(),
    );

    if (result == null || !context.mounted) return;

    try {
      await cubit.addExpense(
        title: result.title,
        category: result.category,
        amount: result.amount,
      );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.expenseAddedSuccess)),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
    }
  }
}

class _ExpenseInput {
  const _ExpenseInput({
    required this.title,
    required this.category,
    required this.amount,
  });

  final String title;
  final String category;
  final double amount;
}

class _AddExpenseSheetBody extends StatefulWidget {
  const _AddExpenseSheetBody();

  @override
  State<_AddExpenseSheetBody> createState() => _AddExpenseSheetBodyState();
}

class _AddExpenseSheetBodyState extends State<_AddExpenseSheetBody> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  var _categoryKey = AppConstants.expenseCategoryKeys.last;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: l10n.expenseTitle,
            prefixIcon: const Icon(Icons.title_outlined),
            hintText: l10n.expenseTitleHint,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: _categoryKey,
          decoration: InputDecoration(
            labelText: l10n.category,
            prefixIcon: const Icon(Icons.category_outlined),
          ),
          items: AppConstants.expenseCategoryKeys
              .map(
                (key) => DropdownMenuItem(
                  value: key,
                  child: Text(AppConstants.categoryLabel(l10n, key)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _categoryKey = v ?? _categoryKey),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          textDirection: TextDirection.ltr,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.amount,
            prefixIcon: const Icon(Icons.attach_money_rounded),
            hintText: l10n.amountHint,
          ),
        ),
        const SizedBox(height: 20),
        GradientButton(
          label: l10n.saveExpense,
          icon: Icons.save_outlined,
          onPressed: () {
            final amount = parseLocalizedDouble(_amountController.text) ?? 0;
            final title = _titleController.text.trim();
            if (title.isEmpty || amount <= 0) return;
            Navigator.of(context).pop(
              _ExpenseInput(title: title, category: _categoryKey, amount: amount),
            );
          },
        ),
      ],
    );
  }
}
