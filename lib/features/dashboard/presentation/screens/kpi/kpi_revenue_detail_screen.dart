import 'package:flutter/material.dart';
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

class KpiRevenueDetailScreen extends StatefulWidget {
  const KpiRevenueDetailScreen({super.key});

  @override
  State<KpiRevenueDetailScreen> createState() => _KpiRevenueDetailScreenState();
}

class _KpiRevenueDetailScreenState extends State<KpiRevenueDetailScreen> {
  RevenueBreakdown? _breakdown;
  Map<String, GymUser> _usersById = {};
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
      final breakdown = await repo.loadRevenueBreakdown();
      final users = await repo.loadUsers();
      if (!mounted) return;
      setState(() {
        _breakdown = breakdown;
        _usersById = {for (final u in users) u.id: u};
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFmt = DateFormat.yMMMd('ar_EG');
    final timeFmt = DateFormat.jm('ar_EG');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.revenue)),
      body: _loading
          ? const AppLoadingView()
          : _error != null
              ? AppErrorView(
                  message: _error!,
                  errorTitle: l10n.somethingWentWrong,
                  retryLabel: l10n.tryAgain,
                  onRetry: _load,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
                    children: [
                      Text(
                        l10n.revenueBreakdownSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      KpiStatCard(
                        label: l10n.totalRevenue,
                        value: CurrencyFormatter.format(_breakdown!.totalRevenue),
                        icon: Icons.trending_up_rounded,
                        iconColor: AppColors.accentGreen,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: KpiStatCard(
                              label: l10n.revenueFromSubscriptions,
                              value: CurrencyFormatter.format(_breakdown!.subscriptionTotal),
                              icon: Icons.card_membership_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: KpiStatCard(
                              label: l10n.revenueFromVisitorSessions,
                              value: CurrencyFormatter.format(_breakdown!.todayVisitorSessionTotal),
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                      if (_breakdown!.todayMemberSessionTotal > 0) ...[
                        const SizedBox(height: AppSpacing.md),
                        KpiStatCard(
                          label: l10n.memberSessionsToday,
                          value: CurrencyFormatter.format(_breakdown!.todayMemberSessionTotal),
                          icon: Icons.people_alt_rounded,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      AppSectionHeader(
                        title: l10n.allSubscriptions,
                        badge: '${_breakdown!.subscriptionCount}',
                      ),
                      if (_breakdown!.subscriptions.isEmpty)
                        AppEmptyState(
                          title: l10n.noActiveSubscription,
                          subtitle: l10n.allMembershipsUpToDate,
                          icon: Icons.event_available_rounded,
                        )
                      else
                        ..._breakdown!.subscriptions.map((sub) {
                          final user = _usersById[sub.userId];
                          final name =
                              user?.name ?? sub.memberName ?? l10n.memberDefault;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: Theme.of(context).textTheme.titleMedium),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${l10n.subscriptionEndDate}: ${dateFmt.format(sub.endDate)}',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(sub.amount),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.accentGreen,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: AppSpacing.lg),
                      AppSectionHeader(
                        title: l10n.todayPaidSessions,
                        badge: '${_breakdown!.todaySessionCount}',
                      ),
                      if (_breakdown!.todaySessions.isEmpty)
                        AppEmptyState(
                          title: l10n.noCheckInsToday,
                          subtitle: l10n.noCheckInsSubtitle,
                          icon: Icons.event_busy_rounded,
                        )
                      else
                        ..._breakdown!.todaySessions.map((record) {
                          final isMember = record.userType == 'member';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record.userName,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          timeFmt.format(record.attendanceTime.toLocal()),
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (record.amountPaid > 0)
                                    Text(
                                      CurrencyFormatter.format(record.amountPaid),
                                      style: Theme.of(context).textTheme.labelLarge,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isMember ? l10n.memberBadge : l10n.visitorBadge,
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}
