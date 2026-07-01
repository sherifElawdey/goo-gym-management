import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/features/users/presentation/screens/member_profile_screen.dart';
import 'package:gym_pro_manager/core/widgets/app_error_view.dart';
import 'package:gym_pro_manager/core/widgets/app_loading_view.dart';
import 'package:gym_pro_manager/core/widgets/kpi_stat_card.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';
import 'package:gym_pro_manager/injection_container.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/widgets/subscription_alert_row.dart';
import 'package:gym_pro_manager/features/users/presentation/cubit/users_cubit.dart';
import 'package:gym_pro_manager/core/widgets/app_empty_state.dart';

class KpiEndedSubscriptionsDetailScreen extends StatefulWidget {
  const KpiEndedSubscriptionsDetailScreen({
    super.key,
    required this.usersCubit,
    this.onDataChanged,
  });

  final UsersCubit usersCubit;
  final VoidCallback? onDataChanged;

  @override
  State<KpiEndedSubscriptionsDetailScreen> createState() =>
      _KpiEndedSubscriptionsDetailScreenState();
}

class _KpiEndedSubscriptionsDetailScreenState extends State<KpiEndedSubscriptionsDetailScreen> {
  List<Subscription> _subscriptions = [];
  Map<String, GymUser> _usersById = {};
  String? _error;
  bool _loading = true;
  String? _endingSubscriptionId;

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
      final stats = await repo.loadDashboardStats();
      final users = await repo.loadUsers(filter: 'members');
      if (!mounted) return;
      setState(() {
        _subscriptions = stats.endedSubscriptions;
        _usersById = {for (final u in users) u.id: u};
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppLogger.userMessage(e);
        _loading = false;
      });
    }
  }

  void _openProfile(BuildContext context, Subscription sub) {
    final l10n = context.l10n;
    final user = _usersById[sub.userId];
    final name = user?.name ?? l10n.memberDefault;
    final phone = user?.phone ?? '';
    final member = user ??
        GymUser(
          id: sub.userId,
          name: name,
          phone: phone,
          isMember: true,
          createdAt: DateTime.now(),
          activeSubscription: sub,
        );

    MemberProfileScreen.open(
      context,
      user: member,
      usersCubit: widget.usersCubit,
      onChanged: () {
        widget.onDataChanged?.call();
        _load();
      },
    );
  }

  Future<void> _confirmEndSubscription(BuildContext context, Subscription sub) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (_endingSubscriptionId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.endSubscriptionConfirmTitle),
        content: Text(l10n.endSubscriptionConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.endSubscription),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _endingSubscriptionId = sub.id);
    try {
      await widget.usersCubit.endSubscription(
        subscriptionId: sub.id,
        userId: sub.userId,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.subscriptionEnded)),
      );
      widget.onDataChanged?.call();
      await _load();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _endingSubscriptionId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.endedSubscriptions)),
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
                  child: _subscriptions.isEmpty
                      ? ListView(
                          children: [
                            AppEmptyState(
                              title: l10n.noEndedSubscriptions,
                              subtitle: l10n.allMembershipsUpToDate,
                              icon: Icons.event_available_rounded,
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
                          children: [
                            KpiStatCard(
                              label: l10n.endedSubscriptions,
                              value: '${_subscriptions.length}',
                              icon: Icons.event_busy_rounded,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.endedSubscriptionsSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ..._subscriptions.map((sub) {
                              final user = _usersById[sub.userId];
                              final name = user?.name ?? l10n.memberDefault;
                              final phone = user?.phone ?? '';
                              return SubscriptionAlertRow(
                                subscription: sub,
                                name: name,
                                phone: phone,
                                kind: SubscriptionAlertKind.ended,
                                ending: _endingSubscriptionId == sub.id,
                                onTap: () => _openProfile(context, sub),
                                onEndSubscription: () => _confirmEndSubscription(context, sub),
                              );
                            }),
                          ],
                        ),
                ),
    );
  }
}
