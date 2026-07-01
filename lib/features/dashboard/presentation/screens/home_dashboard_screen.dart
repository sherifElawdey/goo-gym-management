import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/widgets/app_empty_state.dart';
import 'package:gym_pro_manager/core/widgets/app_error_view.dart';
import 'package:gym_pro_manager/core/widgets/app_loading_view.dart';
import 'package:gym_pro_manager/core/widgets/app_section_header.dart';
import 'package:gym_pro_manager/core/widgets/kpi_stat_card.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/screens/kpi/kpi_ended_subscriptions_detail_screen.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/screens/kpi/kpi_today_attendance_detail_screen.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/screens/kpi/kpi_users_list_detail_screen.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/widgets/subscription_alert_row.dart';
import 'package:gym_pro_manager/features/users/presentation/cubit/users_cubit.dart';
import 'package:gym_pro_manager/features/users/presentation/screens/member_profile_screen.dart';
import 'package:gym_pro_manager/injection_container.dart';
import 'package:intl/intl.dart' hide TextDirection;

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    required this.usersCubit,
    required this.onOpenMembersTab,
    required this.onOpenAttendanceTab,
  });

  final UsersCubit usersCubit;
  final void Function(String filter) onOpenMembersTab;
  final VoidCallback onOpenAttendanceTab;

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

  void _openMemberProfile(
    BuildContext context, {
    required Subscription sub,
    required String name,
    required String phone,
    GymUser? user,
  }) {
    final member = user ??
        GymUser(
          id: sub.userId,
          name: name,
          phone: phone,
          isMember: true,
          createdAt: DateTime.now(),
          gender: user?.gender ?? UserGender.male,
          activeSubscription: sub,
        );

    MemberProfileScreen.open(
      context,
      user: member,
      usersCubit: widget.usersCubit,
      onChanged: () {
        context.read<DashboardCubit>().load();
        _loadUserNames();
      },
    );
  }

  // Future<void> _runGenderMigration(BuildContext context) async {
  //   final l10n = context.l10n;
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (dialogContext) => AlertDialog(
  //       title: Text(l10n.migrateGenderConfirmTitle),
  //       content: Text(l10n.migrateGenderConfirmMessage),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(dialogContext, false),
  //           child: Text(l10n.cancel),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(dialogContext, true),
  //           child: Text(l10n.migrateGenderToMale),
  //         ),
  //       ],
  //     ),
  //   );
  //   if (confirmed != true || !context.mounted) return;
  //
  //   try {
  //     final count = await context.read<DashboardCubit>().backfillUserGender();
  //     if (!context.mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(l10n.migrateGenderSuccess(count))),
  //     );
  //     await _loadUserNames();
  //   } catch (e) {
  //     if (!context.mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(AppLogger.userMessage(e))),
  //     );
  //   }
  // }

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
              const SizedBox(height: AppSpacing.md),
              // OutlinedButton.icon(
              //   onPressed: () => _runGenderMigration(context),
              //   icon: const Icon(Icons.male_rounded),
              //   label: Text(l10n.migrateGenderToMale),
              // ),
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
                      l10n.maleMembers,
                      '${stats.maleMembers}',
                      Icons.male_rounded,
                      AppColors.primary,
                      null,
                      null,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => KpiUsersListDetailScreen(
                            title: l10n.maleMembers,
                            filter: 'members',
                            genderFilter: 'male',
                            usersCubit: widget.usersCubit,
                            onOpenMembersTab: () {
                              widget.usersCubit.setMembersGenderFilter('male');
                              widget.onOpenMembersTab('members');
                            },
                          ),
                        ),
                      ),
                    ),
                    (
                      l10n.femaleMembers,
                      '${stats.femaleMembers}',
                      Icons.female_rounded,
                      AppColors.accentRed,
                      null,
                      null,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => KpiUsersListDetailScreen(
                            title: l10n.femaleMembers,
                            filter: 'members',
                            genderFilter: 'female',
                            usersCubit: widget.usersCubit,
                            onOpenMembersTab: () {
                              widget.usersCubit.setMembersGenderFilter('female');
                              widget.onOpenMembersTab('members');
                            },
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
                    (
                      l10n.endedSubscriptions,
                      '${stats.endedSubscriptions.length}',
                      Icons.event_busy_rounded,
                      AppColors.accentRed,
                      null,
                      null,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => KpiEndedSubscriptionsDetailScreen(
                            usersCubit: widget.usersCubit,
                            onDataChanged: () {
                              context.read<DashboardCubit>().load();
                              _loadUserNames();
                            },
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
                  return SubscriptionAlertRow(
                    subscription: sub,
                    name: name,
                    phone: phone,
                    kind: SubscriptionAlertKind.expiring,
                    onTap: () => _openMemberProfile(
                      context,
                      sub: sub,
                      name: name,
                      phone: phone,
                      user: user,
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
