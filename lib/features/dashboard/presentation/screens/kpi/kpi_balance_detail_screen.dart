import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/constants/app_constants.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/currency_formatter.dart';
import 'package:gym_pro_manager/core/widgets/app_empty_state.dart';
import 'package:gym_pro_manager/core/widgets/app_error_view.dart';
import 'package:gym_pro_manager/core/widgets/app_loading_view.dart';
import 'package:gym_pro_manager/core/widgets/app_section_header.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/kpi_stat_card.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';
import 'package:gym_pro_manager/injection_container.dart';
import 'package:intl/intl.dart' hide TextDirection;

class KpiBalanceDetailScreen extends StatefulWidget {
  const KpiBalanceDetailScreen({
    super.key,
    required this.onOpenFinanceTab,
  });

  final VoidCallback onOpenFinanceTab;

  @override
  State<KpiBalanceDetailScreen> createState() => _KpiBalanceDetailScreenState();
}

class _KpiBalanceDetailScreenState extends State<KpiBalanceDetailScreen> {
  RevenueBreakdown? _breakdown;
  List<Expense> _expenses = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = sl<GymRepository>();
      final now = DateTime.now();
      final breakdown = await repo.loadRevenueBreakdown();
      final expenses = await repo.loadExpensesByMonth(now);
      if (!mounted) return;
      setState(() {
        _breakdown = breakdown;
        _expenses = expenses;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  double get _expensesTotal => _expenses.fold<double>(0, (acc, e) => acc + e.amount);

  double get _netBalance => (_breakdown?.totalRevenue ?? 0) - _expensesTotal;

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
    final dateFmt = DateFormat.yMMMd('ar_EG');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.balance)),
      body: _loading
          ? const AppLoadingView()
          : _error != null
              ? AppErrorView(
                  message: _error!,
                  errorTitle: l10n.somethingWentWrong,
                  retryLabel: l10n.tryAgain,
                  onRetry: _load,
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
                          children: [
                            KpiStatCard(
                              label: l10n.netBalance,
                              value: CurrencyFormatter.format(_netBalance),
                              icon: Icons.account_balance_wallet_rounded,
                              iconColor: AppColors.accentAmber,
                              valueColor: _netBalance >= 0
                                  ? AppColors.accentGreen
                                  : AppColors.accentRed,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: KpiStatCard(
                                    label: l10n.totalRevenue,
                                    value: CurrencyFormatter.format(_breakdown!.totalRevenue),
                                    icon: Icons.trending_up_rounded,
                                    iconColor: AppColors.accentGreen,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: KpiStatCard(
                                    label: l10n.totalExpenses,
                                    value: CurrencyFormatter.format(_expensesTotal),
                                    icon: Icons.receipt_long_outlined,
                                    iconColor: AppColors.accentRed,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            AppSectionHeader(
                              title: l10n.monthExpenses,
                              badge: '${_expenses.length}',
                            ),
                            if (_expenses.isEmpty)
                              AppEmptyState(
                                title: l10n.noExpensesThisMonth,
                                subtitle: l10n.noExpensesSubtitle,
                                icon: Icons.receipt_long_outlined,
                              )
                            else
                              ..._expenses.map((e) {
                                final key = AppConstants.normalizeCategoryKey(e.category);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: GlassCard(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _categoryIcon(key),
                                            color: AppColors.primary,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                e.title,
                                                style: Theme.of(context).textTheme.titleMedium,
                                              ),
                                              Text(
                                                AppConstants.categoryLabel(l10n, e.category),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                dateFmt.format(e.createdAt),
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.format(e.amount),
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onOpenFinanceTab();
                          },
                          child: Text(l10n.openInFinanceTab),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
