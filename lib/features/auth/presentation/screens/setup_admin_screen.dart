import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/gradient_background.dart';
import 'package:gym_pro_manager/core/widgets/gradient_button.dart';
import 'package:gym_pro_manager/features/auth/presentation/cubit/auth_cubit.dart';

class SetupAdminScreen extends StatelessWidget {
  const SetupAdminScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Icon(Icons.admin_panel_settings_outlined, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.createOwnerAdmin, style: theme.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.setupAdminSubtitle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xl),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.account, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Text(
                        email.isEmpty ? l10n.signedInAccount : email,
                        style: theme.textTheme.titleMedium,
                        textDirection: TextDirection.ltr,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SetupRow(icon: Icons.shield_outlined, text: l10n.roleAdminFull),
                      _SetupRow(icon: Icons.storage_outlined, text: l10n.firestoreAdminProfile),
                      _SetupRow(icon: Icons.settings_outlined, text: l10n.gymBootstrapConfig),
                    ],
                  ),
                ),
                const Spacer(),
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthErrorState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return GradientButton(
                      label: l10n.createAdminFullAccess,
                      icon: Icons.check_circle_outline,
                      loading: state is AuthLoadingState,
                      onPressed: state is AuthLoadingState
                          ? null
                          : () => context.read<AuthCubit>().claimInitialAdmin(),
                    );
                  },
                ),
                TextButton(
                  onPressed: () => context.read<AuthCubit>().logout(),
                  child: Text(l10n.signOut),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupRow extends StatelessWidget {
  const _SetupRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
