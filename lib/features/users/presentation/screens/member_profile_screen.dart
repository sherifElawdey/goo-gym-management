import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/widgets/gradient_background.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/features/users/presentation/cubit/users_cubit.dart';
import 'package:gym_pro_manager/features/users/presentation/widgets/member_profile_body.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({
    super.key,
    required this.user,
    required this.usersCubit,
    this.onChanged,
  });

  final GymUser user;
  final UsersCubit usersCubit;
  final VoidCallback? onChanged;

  static Future<void> open(
    BuildContext context, {
    required GymUser user,
    required UsersCubit usersCubit,
    VoidCallback? onChanged,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MemberProfileScreen(
          user: user,
          usersCubit: usersCubit,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  final _bodyKey = GlobalKey<MemberProfileBodyState>();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.memberProfile),
        actions: [
          IconButton(
            onPressed: () => _bodyKey.currentState?.editUser(),
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editUser,
          ),
          IconButton(
            onPressed: () => _bodyKey.currentState?.confirmDeleteUser(),
            icon: const Icon(Icons.delete_outline, color: AppColors.accentRed),
            tooltip: l10n.deleteUser,
          ),
        ],
      ),
      body: GradientBackground(
        child: RefreshIndicator(
          onRefresh: () => _bodyKey.currentState?.load() ?? Future.value(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: MemberProfileBody(
              key: _bodyKey,
              user: widget.user,
              usersCubit: widget.usersCubit,
              onChanged: widget.onChanged,
              onDeleted: widget.onChanged,
              onEnded: widget.onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
