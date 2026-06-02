import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/currency_formatter.dart';
import 'package:gym_pro_manager/core/widgets/app_bottom_sheet.dart';
import 'package:gym_pro_manager/core/widgets/app_empty_state.dart';
import 'package:gym_pro_manager/core/widgets/app_error_view.dart';
import 'package:gym_pro_manager/core/widgets/app_loading_view.dart';
import 'package:gym_pro_manager/core/widgets/app_section_header.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/kpi_stat_card.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/screens/kpi/kpi_balance_detail_screen.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/screens/kpi/kpi_revenue_detail_screen.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/screens/kpi/kpi_today_attendance_detail_screen.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/screens/kpi/kpi_users_list_detail_screen.dart';
import 'package:gym_pro_manager/features/users/presentation/cubit/users_cubit.dart';
import 'package:gym_pro_manager/features/users/presentation/widgets/member_profile_sheet.dart';
import 'package:gym_pro_manager/injection_container.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher_string.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    required this.usersCubit,
    required this.onOpenMembersTab,
    required this.onOpenAttendanceTab,
    required this.onOpenFinanceTab,
  });

  final UsersCubit usersCubit;
  final void Function(String filter) onOpenMembersTab;
  final VoidCallback onOpenAttendanceTab;
  final VoidCallback onOpenFinanceTab;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  Map<String, GymUser> _usersById = {};

  @override
  void initState() {
    super.initState();
    _loadUserNames();
  }

  Future<void> _loadUserNames() async {
    try {
      final users = await sl<GymRepository>().loadUsers();
      if (!mounted) return;
      setState(() {
        _usersById = {for (final u in users) u.id: u};
      });
    } catch (_) {}
  }

  void _openExpiringMemberSheet(
    BuildContext context, {
    required Subscription sub,
    required String name,
    required String phone,
    GymUser? user,
  }) {
    final l10n = context.l10n;
    final messengerContext = context;
    final member = user ??
        GymUser(
          id: sub.userId,
          name: name,
          phone: phone,
          isMember: true,
          createdAt: DateTime.now(),
          activeSubscription: sub,
        );

    AppBottomSheet.show(
      context: context,
      title: member.name,
      subtitle: l10n.memberProfile,
      child: MemberProfileSheet(
        user: member,
        usersCubit: widget.usersCubit,
        messengerContext: messengerContext,
        onSubscriptionEnded: () {
          context.read<DashboardCubit>().load();
          _loadUserNames();
        },
        onUserChanged: () {
          context.read<DashboardCubit>().load();
          _loadUserNames();
        },
        onUserDeleted: () {
          context.read<DashboardCubit>().load();
          _loadUserNames();
        },
      ),
    );
  }

  String _greeting(BuildContext context) {
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<DashboardCubit>().load();
        await _loadUserNames();
      },
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoadingState) {
            return const AppLoadingView(itemCount: 5);
          }
          if (state is DashboardErrorState) {
            return AppErrorView(
              message: state.message,
              errorTitle: l10n.somethingWentWrong,
              retryLabel: l10n.tryAgain,
              onRetry: () => context.read<DashboardCubit>().load(),
            );
          }
          if (state is! DashboardLoadedState) {
            return const SizedBox.shrink();
          }

          final stats = state.stats;
          final dateFmt = DateFormat.yMMMMEEEEd('ar_EG');

          return ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              100,
            ),
            children: [
              Text(_greeting(context), style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(dateFmt.format(DateTime.now()), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth > 600 ? 4 : 2;
                  final cardWidth = (constraints.maxWidth - (crossCount - 1) * 12) / crossCount;
                  final kpis = [
                    (
                      l10n.members,
                      '${stats.totalMembers}',
                      Icons.people_alt_rounded,
                      AppColors.primary,
                      null,
                      null,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => KpiUsersListDetailScreen(
                            title: l10n.members,
                            filter: 'members',
                            usersCubit: widget.usersCubit,
                            onOpenMembersTab: () => widget.onOpenMembersTab('members'),
                          ),
                        ),
                      ),
                    ),
                    (
                      l10n.visitors,
                      '${stats.totalNonMembers}',
                      Icons.person_outline_rounded,
                      AppColors.primaryLight,
                      null,
                      null,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => KpiUsersListDetailScreen(
                            title: l10n.visitors,
                            filter: 'non_members',
                            usersCubit: widget.usersCubit,
                            onOpenMembersTab: () => widget.onOpenMembersTab('non_members'),
                          ),
                        ),
                      ),
                    ),
                    (
                      l10n.revenue,
                      CurrencyFormatter.format(stats.monthlyRevenue),
                      Icons.trending_up_rounded,
                      AppColors.accentGreen,
                      l10n.trendUp,
                      null,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const KpiRevenueDetailScreen(),
                        ),
                      ),
                    ),
                    (
                      l10n.balance,
                      CurrencyFormatter.format(stats.currentBalance),
                      Icons.account_balance_wallet_rounded,
                      AppColors.accentAmber,
                      null,
                      stats.currentBalance >= 0 ? AppColors.accentGreen : AppColors.accentRed,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => KpiBalanceDetailScreen(
                            onOpenFinanceTab: widget.onOpenFinanceTab,
                          ),
                        ),
                      ),
                    ),
                    (
                      l10n.todayAttendance,
                      '${stats.totalAttendanceToday}',
                      Icons.fact_check_rounded,
                      AppColors.primary,
                      null,
                      null,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => KpiTodayAttendanceDetailScreen(
                            onOpenAttendanceTab: widget.onOpenAttendanceTab,
                          ),
                        ),
                      ),
                    ),
                  ];
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: kpis
                        .map(
                          (k) => SizedBox(
                            width: cardWidth,
                            child: KpiStatCard(
                              label: k.$1,
                              value: k.$2,
                              icon: k.$3,
                              iconColor: k.$4,
                              trendLabel: k.$5,
                              valueColor: k.$6,
                              onTap: k.$7,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              AppSectionHeader(
                title: l10n.expiringSoon,
                subtitle: l10n.expiringSoonSubtitle,
                badge: '${stats.expiringSubscriptions.length}',
              ),
              if (stats.expiringSubscriptions.isEmpty)
                AppEmptyState(
                  title: l10n.noExpiringSubscriptions,
                  subtitle: l10n.allMembershipsUpToDate,
                  icon: Icons.event_available_rounded,
                )
              else
                ...stats.expiringSubscriptions.map((sub) {
                  final user = _usersById[sub.userId];
                  final name = user?.name ?? l10n.memberDefault;
                  final phone = user?.phone ?? '';
                  final urgency = AppColors.expiryUrgency(sub.remainingDays);
                  final endDateStr = DateFormat.yMMMd('ar_EG').format(sub.endDate);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: GlassCard(
                      onTap: () => _openExpiringMemberSheet(
                        context,
                        sub: sub,
                        name: name,
                        phone: phone,
                        user: user,
                      ),
                      borderColor: urgency.withValues(alpha: 0.5),
                      backgroundColor: urgency.withValues(alpha: 0.08),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 48,
                            decoration: BoxDecoration(
                              color: urgency,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(
                                  phone.isEmpty ? l10n.noPhoneOnFile : phone,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textDirection: TextDirection.ltr,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.endsOnDaysLeft(endDateStr, sub.remainingDays),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: urgency,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (phone.isNotEmpty)
                            IconButton.filledTonal(
                              onPressed: () async {
                                final message = l10n.whatsappReminder(name, endDateStr);
                                await launchUrlString(
                                  'https://wa.me/${phone.replaceAll(RegExp(r'\D'), '')}?text=${Uri.encodeComponent(message)}',
                                );
                              },
                              icon: const Icon(Icons.chat_rounded),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
