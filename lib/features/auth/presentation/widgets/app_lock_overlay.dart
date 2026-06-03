import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/services/biometric_service.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/gradient_background.dart';
import 'package:gym_pro_manager/core/widgets/gradient_button.dart';
import 'package:gym_pro_manager/features/auth/presentation/widgets/unlock_password_sheet.dart';
import 'package:gym_pro_manager/injection_container.dart';

enum AppLockTarget { shell, financeAmounts }

class AppLockGate extends StatelessWidget {
  const AppLockGate({
    super.key,
    required this.locked,
    required this.target,
    required this.onUnlocked,
    required this.lockSession,
    this.onAuthStarted,
    this.onAuthFinished,
    required this.child,
  });

  final bool locked;
  final AppLockTarget target;
  final VoidCallback onUnlocked;
  final int lockSession;
  final VoidCallback? onAuthStarted;
  final VoidCallback? onAuthFinished;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (locked)
          AppLockOverlay(
            key: ValueKey(lockSession),
            target: target,
            onUnlocked: onUnlocked,
            onAuthStarted: onAuthStarted,
            onAuthFinished: onAuthFinished,
          ),
      ],
    );
  }
}

class AppLockOverlay extends StatefulWidget {
  const AppLockOverlay({
    super.key,
    required this.target,
    required this.onUnlocked,
    this.onAuthStarted,
    this.onAuthFinished,
  });

  final AppLockTarget target;
  final VoidCallback onUnlocked;
  final VoidCallback? onAuthStarted;
  final VoidCallback? onAuthFinished;

  @override
  State<AppLockOverlay> createState() => _AppLockOverlayState();
}

class _AppLockOverlayState extends State<AppLockOverlay> {
  final _biometricService = sl<BiometricService>();
  bool _biometricAvailable = true;
  bool _authenticating = false;
  bool _didAutoPrompt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didAutoPrompt) return;
      _didAutoPrompt = true;
      _tryBiometric();
    });
  }

  String _biometricReason(BuildContext context) {
    final l10n = context.l10n;
    return widget.target == AppLockTarget.shell
        ? l10n.biometricPromptShell
        : l10n.biometricPromptFinanceAmounts;
  }

  Future<void> _tryBiometric() async {
    if (!mounted || _authenticating) return;
    setState(() => _authenticating = true);

    final available = await _biometricService.isAvailable();
    final deviceSupported = await _biometricService.isDeviceSupported();
    if (!mounted) return;

    setState(() {
      _biometricAvailable = available || deviceSupported;
      _authenticating = false;
    });

    if (!available && !deviceSupported) return;

    widget.onAuthStarted?.call();
    setState(() => _authenticating = true);
    final result = await _biometricService.authenticateWithDetails(
      reason: _biometricReason(context),
    );
    widget.onAuthFinished?.call();
    if (!mounted) return;

    setState(() => _authenticating = false);
    if (result.success) {
      widget.onUnlocked();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.biometricFailedTryAgain)),
    );
  }

  Future<void> _openPasswordSheet() async {
    widget.onAuthStarted?.call();
    final unlocked = await UnlockPasswordSheet.show(context: context);
    widget.onAuthFinished?.call();
    if (unlocked == true && mounted) {
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: GlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.fingerprint_rounded,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.lockScreenTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.lockScreenSubtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (!_biometricAvailable) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.biometricUnavailable,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      if (_biometricAvailable)
                        GradientButton(
                          label: l10n.unlockWithBiometric,
                          icon: Icons.fingerprint_rounded,
                          loading: _authenticating,
                          onPressed: _authenticating ? null : _tryBiometric,
                        ),
                      if (_biometricAvailable) const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: _authenticating ? null : _openPasswordSheet,
                        icon: const Icon(Icons.lock_outline_rounded),
                        label: Text(l10n.unlockWithPassword),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
