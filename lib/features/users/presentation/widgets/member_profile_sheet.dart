import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/core/utils/currency_formatter.dart';
import 'package:gym_pro_manager/core/widgets/app_bottom_sheet.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/gradient_button.dart';
import 'package:gym_pro_manager/core/widgets/member_avatar.dart';
import 'package:gym_pro_manager/core/widgets/status_badge.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/features/users/presentation/cubit/users_cubit.dart';
import 'package:gym_pro_manager/features/users/presentation/widgets/edit_user_sheet.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// Profile body shown inside [AppBottomSheet]. Requires [usersCubit] and
/// [messengerContext] from the screen that opened the sheet (modal routes
/// do not inherit [UsersCubit] or [ScaffoldMessenger] from the tab).
class MemberProfileSheet extends StatefulWidget {
  const MemberProfileSheet({
    super.key,
    required this.user,
    required this.usersCubit,
    required this.messengerContext,
    this.onSubscriptionEnded,
    this.onUserChanged,
    this.onUserDeleted,
  });

  final GymUser user;
  final UsersCubit usersCubit;
  final BuildContext messengerContext;
  final VoidCallback? onSubscriptionEnded;
  final VoidCallback? onUserChanged;
  final VoidCallback? onUserDeleted;

  @override
  State<MemberProfileSheet> createState() => _MemberProfileSheetState();
}

class _MemberProfileSheetState extends State<MemberProfileSheet> {
  late GymUser _user;
  Subscription? _subscription;
  bool _loading = true;
  bool _renewing = false;
  bool _ending = false;
  bool _deleting = false;
  String? _error;

  ScaffoldMessengerState get _messenger => ScaffoldMessenger.of(widget.messengerContext);

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final subs = await widget.usersCubit.loadUserSubscriptions(_user.id);
      if (!mounted) return;
      setState(() {
        _subscription = subs.isNotEmpty ? subs.first : _user.activeSubscription;
        _loading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.error('MemberProfileSheet._load', e, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _error = AppLogger.userMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _confirmEndSubscription() async {
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
    await _endSubscription();
  }

  Future<void> _endSubscription() async {
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
      _messenger.showSnackBar(
        SnackBar(content: Text(l10n.subscriptionEnded)),
      );
      widget.onSubscriptionEnded?.call();
      widget.onUserChanged?.call();
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      AppLogger.error('MemberProfileSheet._endSubscription', e, stackTrace: stackTrace);
      if (!mounted) return;
      _messenger.showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
      setState(() => _ending = false);
    }
  }

  Future<void> _editUser() async {
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
      _messenger.showSnackBar(
        SnackBar(content: Text(l10n.userUpdatedSuccess)),
      );
      widget.onUserChanged?.call();
    } catch (e, stackTrace) {
      AppLogger.error('MemberProfileSheet._editUser', e, stackTrace: stackTrace);
      if (!mounted) return;
      _messenger.showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
    }
  }

  Future<void> _confirmDeleteUser() async {
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
    await _deleteUser();
  }

  Future<void> _deleteUser() async {
    final l10n = context.l10n;
    if (_deleting) return;

    setState(() => _deleting = true);
    try {
      await widget.usersCubit.deleteUser(_user.id);
      if (!mounted) return;
      _messenger.showSnackBar(
        SnackBar(content: Text(l10n.userDeletedSuccess)),
      );
      widget.onUserDeleted?.call();
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      AppLogger.error('MemberProfileSheet._deleteUser', e, stackTrace: stackTrace);
      if (!mounted) return;
      _messenger.showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
      setState(() => _deleting = false);
    }
  }

  Future<void> _renew() async {
    final l10n = context.l10n;
    final sub = _subscription;
    if (sub == null || _renewing) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: sub.endDate.isAfter(DateTime.now()) ? sub.endDate : DateTime.now(),
      firstDate: sub.startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      locale: const Locale('ar', 'EG'),
    );
    if (picked == null || !mounted) return;

    final endKey = DateTime(picked.year, picked.month, picked.day);
    final startKey = DateTime(sub.startDate.year, sub.startDate.month, sub.startDate.day);
    if (endKey.isBefore(startKey)) {
      _messenger.showSnackBar(
        SnackBar(content: Text(l10n.endDateBeforeStart)),
      );
      return;
    }

    setState(() => _renewing = true);
    try {
      await widget.usersCubit.updateSubscriptionEndDate(
        subscriptionId: sub.id,
        endDate: picked,
      );
      if (!mounted) return;
      _messenger.showSnackBar(
        SnackBar(content: Text(l10n.subscriptionRenewed)),
      );
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      AppLogger.error('MemberProfileSheet._renew', e, stackTrace: stackTrace);
      if (!mounted) return;
      _messenger.showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
      setState(() => _renewing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileHeader(
          user: _user,
          busy: _deleting || _renewing || _ending,
          onEdit: _editUser,
          onDelete: _confirmDeleteUser,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_loading) const _LoadingBlock(),
        if (!_loading && _error != null)
          _ErrorBlock(
            message: _error!,
            errorTitle: l10n.somethingWentWrong,
            retryLabel: l10n.tryAgain,
            onRetry: _load,
          ),
        if (!_loading && _error == null)
          _SubscriptionBlock(
            user: _user,
            subscription: _subscription,
            renewing: _renewing,
            ending: _ending,
            deleting: _deleting,
            onRenew: _renew,
            onEnd: _confirmEndSubscription,
          ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final GymUser user;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MemberAvatar(name: user.name, size: 56),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      user.phone.isEmpty ? l10n.noPhone : user.phone,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              user.isMember
                  ? StatusBadge.member(context, l10n.memberBadge)
                  : StatusBadge.visitor(context, l10n.visitorBadge),
            ],
          ),
        ),
        IconButton(
          onPressed: busy ? null : onEdit,
          icon: const Icon(Icons.edit_outlined),
          tooltip: l10n.editUser,
        ),
        IconButton(
          onPressed: busy ? null : onDelete,
          icon: Icon(Icons.delete_outline, color: busy ? null : AppColors.accentRed),
          tooltip: l10n.deleteUser,
        ),
      ],
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
    required this.onEnd,
  });

  final GymUser user;
  final Subscription? subscription;
  final bool renewing;
  final bool ending;
  final bool deleting;
  final VoidCallback onRenew;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFmt = DateFormat.yMMMd('ar_EG');
    final sub = subscription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.subscriptionDetails, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        if (sub == null)
          GlassCard(
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
          )
        else ...[
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
                  valueColor:
                      sub.status == 'active' ? AppColors.accentGreen : AppColors.accentRed,
                ),
              ],
            ),
          ),
          if (sub.remainingDays >= 0) ...[
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
          ],
          if (user.isMember && sub.status == 'active') ...[
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              label: l10n.renewSubscription,
              icon: Icons.autorenew_rounded,
              loading: renewing,
              onPressed: renewing || ending || deleting ? null : onRenew,
            ),
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
      ],
    );
  }

  Color? _endDateColor(Subscription sub) {
    final days = sub.remainingDays;
    if (days < 0) return AppColors.accentRed;
    if (days <= 5) return AppColors.accentAmber;
    return null;
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
