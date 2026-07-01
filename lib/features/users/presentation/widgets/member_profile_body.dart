import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/constants/app_constants.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/core/utils/currency_formatter.dart';
import 'package:gym_pro_manager/core/widgets/app_bottom_sheet.dart';
import 'package:gym_pro_manager/core/widgets/app_section_header.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/gradient_button.dart';
import 'package:gym_pro_manager/core/widgets/member_avatar.dart';
import 'package:gym_pro_manager/core/widgets/status_badge.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/features/users/presentation/cubit/users_cubit.dart';
import 'package:gym_pro_manager/features/users/presentation/widgets/edit_subscription_sheet.dart';
import 'package:gym_pro_manager/features/users/presentation/widgets/edit_user_sheet.dart';
import 'package:gym_pro_manager/features/users/presentation/widgets/renew_subscription_dialog.dart';
import 'package:intl/intl.dart' hide TextDirection;

class MemberProfileBody extends StatefulWidget {
  const MemberProfileBody({
    super.key,
    required this.user,
    required this.usersCubit,
    this.onChanged,
    this.onDeleted,
    this.onEnded,
  });

  final GymUser user;
  final UsersCubit usersCubit;
  final VoidCallback? onChanged;
  final VoidCallback? onDeleted;
  final VoidCallback? onEnded;

  @override
  State<MemberProfileBody> createState() => MemberProfileBodyState();
}

class MemberProfileBodyState extends State<MemberProfileBody> {
  late GymUser _user;
  List<Subscription> _subscriptions = [];
  Subscription? _subscription;
  bool _loading = true;
  bool _renewing = false;
  bool _ending = false;
  bool _deleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    load();
  }

  Future<void> load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final subs = await widget.usersCubit.loadUserSubscriptions(_user.id);
      if (!mounted) return;
      setState(() {
        _subscriptions = subs;
        _subscription = subs.isNotEmpty
            ? subs.firstWhere(
                (s) => s.status == 'active',
                orElse: () => subs.first,
              )
            : _user.activeSubscription;
        _loading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.error('MemberProfileBody.load', e, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _error = AppLogger.userMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> confirmEndSubscription() async {
    final l10n = context.l10n;
    final sub = _subscription;
    if (sub == null || _ending) return;

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
    await endSubscription();
  }

  Future<void> endSubscription() async {
    final l10n = context.l10n;
    final sub = _subscription;
    if (sub == null || _ending) return;

    setState(() => _ending = true);
    try {
      await widget.usersCubit.endSubscription(
        subscriptionId: sub.id,
        userId: _user.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subscriptionEnded)),
      );
      widget.onEnded?.call();
      widget.onChanged?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e, stackTrace) {
      AppLogger.error('MemberProfileBody.endSubscription', e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
      setState(() => _ending = false);
    }
  }

  Future<void> editUser() async {
    final l10n = context.l10n;
    if (_deleting) return;

    final result = await AppBottomSheet.show<EditUserResult>(
      context: context,
      title: l10n.editUserSheetTitle,
      child: EditUserSheet(user: _user),
    );
    if (result == null || !mounted) return;

    try {
      await widget.usersCubit.updateUser(
        userId: _user.id,
        name: result.name,
        phone: result.phone,
      );
      if (!mounted) return;
      setState(() {
        _user = GymUser(
          id: _user.id,
          name: result.name,
          phone: result.phone,
          isMember: _user.isMember,
          createdAt: _user.createdAt,
          gender: _user.gender,
          activeSubscription: _user.activeSubscription,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.userUpdatedSuccess)),
      );
      widget.onChanged?.call();
      await load();
    } catch (e, stackTrace) {
      AppLogger.error('MemberProfileBody.editUser', e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
    }
  }

  Future<void> confirmDeleteUser() async {
    final l10n = context.l10n;
    if (_deleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteUserConfirmTitle),
        content: Text(l10n.deleteUserConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.deleteUser,
              style: const TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await deleteUser();
  }

  Future<void> deleteUser() async {
    final l10n = context.l10n;
    if (_deleting) return;

    setState(() => _deleting = true);
    try {
      await widget.usersCubit.deleteUser(_user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.userDeletedSuccess)),
      );
      widget.onDeleted?.call();
      widget.onChanged?.call();
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      AppLogger.error('MemberProfileBody.deleteUser', e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
      setState(() => _deleting = false);
    }
  }

  Future<void> renew() async {
    final l10n = context.l10n;
    if (_renewing || !_user.isMember) return;

    final amount = _subscription?.amount ?? AppConstants.defaultMonthlySubscriptionFeeEgp;
    final result = await RenewSubscriptionDialog.show(
      context,
      initialStartDate: RenewSubscriptionDialog.defaultRenewStartDate(),
      initialEndDate: RenewSubscriptionDialog.defaultRenewEndDate(),
      initialAmount: amount,
    );
    if (result == null || !mounted) return;

    setState(() => _renewing = true);
    try {
      await widget.usersCubit.renewMemberSubscription(
        userId: _user.id,
        startDate: result.startDate,
        endDate: result.endDate,
        amount: result.amount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subscriptionRenewed)),
      );
      widget.onChanged?.call();
      await load();
    } catch (e, stackTrace) {
      AppLogger.error('MemberProfileBody.renew', e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _renewing = false);
    }
  }

  Future<void> editSubscription() async {
    final l10n = context.l10n;
    final sub = _subscription;
    if (sub == null || isBusy) return;

    final result = await AppBottomSheet.show<EditSubscriptionResult>(
      context: context,
      title: l10n.editSubscriptionSheetTitle,
      child: EditSubscriptionSheet(subscription: sub),
    );
    if (result == null || !mounted) return;

    try {
      await widget.usersCubit.updateSubscription(
        subscriptionId: sub.id,
        startDate: result.startDate,
        endDate: result.endDate,
        amount: result.amount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subscriptionUpdated)),
      );
      widget.onChanged?.call();
      await load();
    } catch (e, stackTrace) {
      AppLogger.error('MemberProfileBody.editSubscription', e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
    }
  }

  bool get isBusy => _deleting || _renewing || _ending;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFmt = DateFormat.yMMMd('ar_EG');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileHeroCard(user: _user, memberSince: dateFmt.format(_user.createdAt)),
        const SizedBox(height: AppSpacing.xl),
        if (_loading) const _LoadingBlock(),
        if (!_loading && _error != null)
          _ErrorBlock(
            message: _error!,
            errorTitle: l10n.somethingWentWrong,
            retryLabel: l10n.tryAgain,
            onRetry: load,
          ),
        if (!_loading && _error == null) ...[
          AppSectionHeader(title: l10n.currentSubscription),
          const SizedBox(height: AppSpacing.sm),
          _SubscriptionBlock(
            user: _user,
            subscription: _subscription,
            renewing: _renewing,
            ending: _ending,
            deleting: _deleting,
            onRenew: renew,
            onEdit: editSubscription,
            onEnd: confirmEndSubscription,
          ),
          if (_subscriptions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(title: l10n.subscriptionHistory),
            const SizedBox(height: AppSpacing.sm),
            _SubscriptionHistorySection(
              subscriptions: _subscriptions,
              currentSubscriptionId: _subscription?.id,
            ),
          ],
        ],
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.user, required this.memberSince});

  final GymUser user;
  final String memberSince;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          MemberAvatar(name: user.name, size: 72),
          const SizedBox(height: AppSpacing.md),
          Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            user.phone.isEmpty ? l10n.noPhone : user.phone,
            style: Theme.of(context).textTheme.bodyLarge,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${l10n.memberSince} $memberSince',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (user.isMember)
                StatusBadge(
                  label: user.gender == UserGender.female
                      ? l10n.genderFemale
                      : l10n.genderMale,
                  color: user.gender == UserGender.female
                      ? AppColors.accentRed
                      : AppColors.primary,
                ),
              user.isMember
                  ? StatusBadge.member(context, l10n.memberBadge)
                  : StatusBadge.visitor(context, l10n.visitorBadge),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({
    required this.message,
    required this.errorTitle,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String errorTitle;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.accentRed),
          const SizedBox(height: AppSpacing.md),
          Text(
            errorTitle,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionBlock extends StatelessWidget {
  const _SubscriptionBlock({
    required this.user,
    required this.subscription,
    required this.renewing,
    required this.ending,
    required this.deleting,
    required this.onRenew,
    required this.onEdit,
    required this.onEnd,
  });

  final GymUser user;
  final Subscription? subscription;
  final bool renewing;
  final bool ending;
  final bool deleting;
  final VoidCallback onRenew;
  final VoidCallback onEdit;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFmt = DateFormat.yMMMd('ar_EG');
    final sub = subscription;

    if (sub == null) {
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                l10n.noActiveSubscription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final statusColor =
        sub.status == 'active' ? AppColors.accentGreen : AppColors.accentRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Column(
            children: [
              _DetailTile(
                icon: Icons.calendar_today_outlined,
                label: l10n.subscriptionStartDate,
                value: dateFmt.format(sub.startDate),
              ),
              const Divider(height: 1),
              _DetailTile(
                icon: Icons.event_outlined,
                label: l10n.subscriptionEndDate,
                value: dateFmt.format(sub.endDate),
                valueColor: _endDateColor(sub),
              ),
              const Divider(height: 1),
              _DetailTile(
                icon: Icons.payments_outlined,
                label: l10n.subscriptionAmount,
                value: CurrencyFormatter.format(sub.amount),
                valueColor: AppColors.primary,
              ),
              const Divider(height: 1),
              _DetailTile(
                icon: Icons.verified_outlined,
                label: l10n.subscriptionStatus,
                value: sub.status == 'active' ? l10n.statusActive : l10n.statusExpired,
                valueColor: statusColor,
              ),
            ],
          ),
        ),
        if (sub.remainingDays > 0) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timelapse_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.daysRemaining(sub.remainingDays),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (sub.status == 'active') ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_busy_rounded, size: 20, color: AppColors.accentRed),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.subscriptionExpired,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (user.isMember) ...[
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: l10n.renewSubscription,
            icon: Icons.autorenew_rounded,
            loading: renewing,
            onPressed: renewing || ending || deleting ? null : onRenew,
          ),
        ],
        if (sub.status == 'active') ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: renewing || ending || deleting ? null : onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.editSubscription),
          ),
        ],
        if (user.isMember && sub.status == 'active') ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: renewing || ending || deleting ? null : onEnd,
            icon: ending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cancel_outlined),
            label: Text(l10n.endSubscription),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentRed,
              side: const BorderSide(color: AppColors.accentRed),
            ),
          ),
        ],
      ],
    );
  }

  Color? _endDateColor(Subscription sub) {
    final days = sub.remainingDays;
    if (days <= 0) return AppColors.accentRed;
    if (days <= AppConstants.expiringSoonMaxDays) return AppColors.accentAmber;
    return null;
  }
}

class _SubscriptionHistorySection extends StatelessWidget {
  const _SubscriptionHistorySection({
    required this.subscriptions,
    required this.currentSubscriptionId,
  });

  final List<Subscription> subscriptions;
  final String? currentSubscriptionId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFmt = DateFormat.yMMMd('ar_EG');

    return Column(
      children: subscriptions.map((sub) {
        final isCurrent = sub.id == currentSubscriptionId;
        final accent = sub.status == 'active' ? AppColors.accentGreen : AppColors.accentRed;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GlassCard(
            borderColor: isCurrent ? AppColors.primary.withValues(alpha: 0.4) : null,
            backgroundColor: isCurrent ? AppColors.primary.withValues(alpha: 0.06) : null,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dateFmt.format(sub.startDate)} — ${dateFmt.format(sub.endDate)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyFormatter.format(sub.amount),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                sub.status == 'active'
                    ? StatusBadge.member(context, l10n.statusActive)
                    : StatusBadge(label: l10n.statusExpired, color: AppColors.accentRed),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary.withValues(alpha: 0.85)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: valueColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
