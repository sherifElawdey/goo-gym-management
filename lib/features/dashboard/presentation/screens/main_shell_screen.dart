import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/services/biometric_service.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/widgets/branded_app_bar.dart';
import 'package:gym_pro_manager/core/widgets/gradient_background.dart';
import 'package:gym_pro_manager/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:gym_pro_manager/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:gym_pro_manager/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gym_pro_manager/features/auth/presentation/widgets/app_lock_overlay.dart';
import 'package:gym_pro_manager/features/auth/presentation/widgets/unlock_password_sheet.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/screens/home_dashboard_screen.dart';
import 'package:gym_pro_manager/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:gym_pro_manager/features/finance/presentation/screens/finance_screen.dart';
import 'package:gym_pro_manager/features/users/presentation/cubit/users_cubit.dart';
import 'package:gym_pro_manager/features/users/presentation/screens/users_screen.dart';
import 'package:gym_pro_manager/injection_container.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> with WidgetsBindingObserver {
  int _index = 0;
  bool _shellLocked = true;
  bool _financeAmountsVisible = false;
  int _lockSession = 0;
  bool _wasInBackground = false;
  bool _authInProgress = false;

  final _biometricService = sl<BiometricService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_authInProgress) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      if (!_shellLocked) {
        _wasInBackground = true;
      }
      return;
    }

    if (state == AppLifecycleState.resumed && _wasInBackground && !_shellLocked) {
      _wasInBackground = false;
      _lockShell();
    }
  }

  void _lockShell() {
    setState(() {
      _shellLocked = true;
      _financeAmountsVisible = false;
      _lockSession++;
    });
  }

  void _onAuthStarted() => _authInProgress = true;

  void _onAuthFinished() => _authInProgress = false;

  void _selectTab(int i) {
    setState(() {
      _index = i;
      if (i == 3) {
        _financeAmountsVisible = false;
      }
    });
  }

  Future<bool> _authenticateUser(BuildContext context, String reason) async {
    _authInProgress = true;
    try {
      final available = await _biometricService.isAvailable();
      final deviceSupported = await _biometricService.isDeviceSupported();

      if (available || deviceSupported) {
        final result = await _biometricService.authenticateWithDetails(reason: reason);
        if (result.success) return true;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.biometricFailedTryAgain)),
          );
        }
      }

      if (!context.mounted) return false;
      final ok = await UnlockPasswordSheet.show(context: context);
      return ok == true;
    } finally {
      _authInProgress = false;
    }
  }

  Future<bool> _revealFinanceAmounts(BuildContext context) async {
    final success = await _authenticateUser(context, context.l10n.biometricPromptFinanceAmounts);
    if (success && mounted) {
      setState(() => _financeAmountsVisible = true);
    }
    return success;
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  void _openMembersTab(BuildContext shellContext, String filter) {
    shellContext.read<UsersCubit>().setFilter(filter);
    _selectTab(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titles = [l10n.navHome, l10n.navAttendance, l10n.navMembers, l10n.navFinance];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DashboardCubit>()..load()),
        BlocProvider(create: (_) => sl<AttendanceCubit>()..load()),
        BlocProvider(create: (_) => sl<UsersCubit>()..load()),
        BlocProvider(create: (_) => sl<FinanceCubit>()..load()),
      ],
      child: Builder(
        builder: (shellContext) {
          return AppLockGate(
            locked: _shellLocked,
            lockSession: _lockSession,
            target: AppLockTarget.shell,
            onUnlocked: () => setState(() => _shellLocked = false),
            onAuthStarted: _onAuthStarted,
            onAuthFinished: _onAuthFinished,
            child: Scaffold(
              extendBody: true,
              appBar: BrandedAppBar(
                title: titles[_index],
                gymName: l10n.gymName,
                actions: [
                  if (_index == 0) ...[
                    IconButton(
                      onPressed: () => shellContext.read<DashboardCubit>().load(),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    IconButton(
                      onPressed: () => _confirmSignOut(context),
                      icon: const Icon(Icons.logout_rounded),
                      tooltip: l10n.signOut,
                    ),
                  ],
                ],
              ),
              body: SafeArea(
                bottom: true,
                child: GradientBackground(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: IndexedStack(
                      index: _index,
                      children: [
                        HomeDashboardScreen(
                          usersCubit: shellContext.read<UsersCubit>(),
                          onOpenMembersTab: (filter) => _openMembersTab(shellContext, filter),
                          onOpenAttendanceTab: () => _selectTab(1),
                          onOpenFinanceTab: () => _selectTab(3),
                        ),
                        const AttendanceScreen(),
                        const UsersScreen(),
                        FinanceScreen(
                          amountsVisible: _financeAmountsVisible,
                          onRevealAmounts: () => _revealFinanceAmounts(shellContext),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: _GlassNavBar(
                index: _index,
                onChanged: _selectTab,
                labels: [l10n.navHome, l10n.navAttendance, l10n.navMembers, l10n.navFinance],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.index,
    required this.onChanged,
    required this.labels,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: onChanged,
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 64,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: labels[0],
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_today_outlined),
                  selectedIcon: const Icon(Icons.calendar_today_rounded),
                  label: labels[1],
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline_rounded),
                  selectedIcon: const Icon(Icons.people_rounded),
                  label: labels[2],
                ),
                NavigationDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
                  label: labels[3],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
