import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/core/widgets/app_empty_state.dart';
import 'package:gym_pro_manager/core/widgets/app_search_field.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/member_avatar.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/features/attendance/presentation/cubit/attendance_cubit.dart';

class RegisterMemberSheet extends StatefulWidget {
  const RegisterMemberSheet({
    super.key,
    required this.attendanceCubit,
    required this.messengerContext,
  });

  final AttendanceCubit attendanceCubit;
  final BuildContext messengerContext;

  @override
  State<RegisterMemberSheet> createState() => _RegisterMemberSheetState();
}

class _RegisterMemberSheetState extends State<RegisterMemberSheet> {
  final _searchController = TextEditingController();
  List<GymUser> _members = [];
  bool _loading = true;
  String? _error;

  ScaffoldMessengerState get _messenger => ScaffoldMessenger.of(widget.messengerContext);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({String query = ''}) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final members = await widget.attendanceCubit.loadMembers(query: query);
      if (!mounted) return;
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.error('RegisterMemberSheet._load', e, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _error = AppLogger.userMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _onMemberTap(GymUser member) async {
    final l10n = context.l10n;
    try {
      await widget.attendanceCubit.registerMemberAttendance(member);
      if (!mounted) return;
      Navigator.of(context).pop();
      _messenger.showSnackBar(
        SnackBar(content: Text(l10n.memberAttendanceRecorded)),
      );
    } catch (e, stackTrace) {
      AppLogger.error('RegisterMemberSheet._onMemberTap', e, stackTrace: stackTrace);
      if (!mounted) return;
      _messenger.showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSearchField(
          controller: _searchController,
          hintText: l10n.searchNameOrPhone,
          onChanged: (q) => _load(query: q),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          _ErrorBlock(
            message: _error!,
            errorTitle: l10n.somethingWentWrong,
            retryLabel: l10n.tryAgain,
            onRetry: () => _load(query: _searchController.text),
          )
        else if (_members.isEmpty)
          AppEmptyState(
            title: _searchController.text.trim().isNotEmpty
                ? l10n.noResultsFound
                : l10n.noMembersToCheckIn,
            subtitle: _searchController.text.trim().isNotEmpty
                ? l10n.tryDifferentSearch
                : l10n.addMembersFromButton,
            icon: Icons.people_outline_rounded,
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _members.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final member = _members[index];
                return GlassCard(
                  onTap: () => _onMemberTap(member),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      MemberAvatar(name: member.name),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (member.phone.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                member.phone,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_left_rounded,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
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
            style: Theme.of(context).textTheme.bodyMedium,
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
