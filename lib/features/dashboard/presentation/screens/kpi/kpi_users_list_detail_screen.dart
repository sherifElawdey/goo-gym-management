import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/features/users/presentation/screens/member_profile_screen.dart';
import 'package:gym_pro_manager/injection_container.dart';
import 'package:gym_pro_manager/core/widgets/app_error_view.dart';
import 'package:gym_pro_manager/core/widgets/app_loading_view.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/kpi_stat_card.dart';
import 'package:gym_pro_manager/core/widgets/member_avatar.dart';
import 'package:gym_pro_manager/core/widgets/status_badge.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';
import 'package:gym_pro_manager/features/users/presentation/cubit/users_cubit.dart';
import 'package:gym_pro_manager/core/widgets/app_empty_state.dart';
import 'package:intl/intl.dart' hide TextDirection;

class KpiUsersListDetailScreen extends StatefulWidget {
  const KpiUsersListDetailScreen({
    super.key,
    required this.title,
    required this.filter,
    required this.usersCubit,
    required this.onOpenMembersTab,
    this.genderFilter,
  });

  final String title;
  final String filter;
  final UsersCubit usersCubit;
  final VoidCallback onOpenMembersTab;
  final String? genderFilter;

  @override
  State<KpiUsersListDetailScreen> createState() => _KpiUsersListDetailScreenState();
}

class _KpiUsersListDetailScreenState extends State<KpiUsersListDetailScreen> {
  List<GymUser>? _users;
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
      final users = await sl<GymRepository>().loadUsers(
        filter: widget.filter,
        genderFilter: widget.genderFilter ?? 'all',
      );
      if (!mounted) return;
      setState(() {
        _users = users;
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

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
                        child: _users!.isEmpty
                            ? ListView(
                                children: [
                                  AppEmptyState(
                                    title: l10n.noMembersYet,
                                    subtitle: l10n.addMembersFromButton,
                                    icon: Icons.people_outline_rounded,
                                  ),
                                ],
                              )
                            : ListView(
                                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
                                children: [
                                  KpiStatCard(
                                    label: widget.title,
                                    value: '${_users!.length}',
                                    icon: widget.filter == 'members'
                                        ? Icons.people_alt_rounded
                                        : Icons.person_outline_rounded,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ..._users!.map((user) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                      child: GlassCard(
                                        onTap: user.isMember
                                            ? () {
                                                MemberProfileScreen.open(
                                                  context,
                                                  user: user,
                                                  usersCubit: widget.usersCubit,
                                                );
                                              }
                                            : null,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            MemberAvatar(name: user.name),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user.name,
                                                    style: Theme.of(context).textTheme.titleMedium,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    user.phone.isEmpty
                                                        ? l10n.noPhone
                                                        : user.phone,
                                                    style: Theme.of(context).textTheme.bodyMedium,
                                                    textDirection: TextDirection.ltr,
                                                  ),
                                                  if (user.activeSubscription != null) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${l10n.subscriptionEndDate}: ${dateFmt.format(user.activeSubscription!.endDate)}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            user.isMember
                                                ? StatusBadge.member(context, l10n.memberBadge)
                                                : StatusBadge.visitor(context, l10n.visitorBadge),
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
                            widget.onOpenMembersTab();
                          },
                          child: Text(l10n.openInMembersTab),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
