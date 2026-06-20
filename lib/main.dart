import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:gym_pro_manager/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:gym_pro_manager/core/controllers/theme_controller.dart';
import 'package:gym_pro_manager/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_pro_manager/core/theme/app_theme.dart';
import 'package:gym_pro_manager/core/widgets/app_loading_view.dart';
import 'package:gym_pro_manager/core/widgets/gradient_background.dart';
import 'package:gym_pro_manager/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gym_pro_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:gym_pro_manager/features/auth/presentation/screens/setup_admin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/screens/main_shell_screen.dart';
import 'package:gym_pro_manager/core/utils/app_bloc_observer.dart';
import 'package:gym_pro_manager/core/utils/app_error_handlers.dart';
import 'package:gym_pro_manager/injection_container.dart';
import 'package:gym_pro_manager/l10n/app_localizations.dart';

Future<void> main() async {
  await runAppWithErrorLogging(() async {
    WidgetsFlutterBinding.ensureInitialized();
    setupGlobalErrorHandlers();
    Bloc.observer = AppBlocObserver();

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await configureDependencies();
    Get.put(ThemeController(sl<SharedPreferences>()), permanent: true);
    runApp(const GooGymApp());
    unawaited(sl<NotificationService>().initialize());
  });
}

class GooGymApp extends StatelessWidget {
  const GooGymApp({super.key});

  static const _locale = Locale('ar', 'EG');

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return BlocProvider(
      create: (_) => sl<AuthCubit>()..checkSession(),
      child: Obx(
        () => MaterialApp(
          title: 'Goo Gym',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode.value,
          locale: _locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          localeResolutionCallback: (locale, supported) => _locale,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthenticatedState) {
                return const MainShellScreen();
              }
              if (state is NeedsBootstrapState) {
                final email = FirebaseAuth.instance.currentUser?.email ?? state.email;
                return SetupAdminScreen(email: email);
              }
              if (state is AuthLoadingState) {
                return const Scaffold(
                  body: GradientBackground(child: Center(child: AppLoadingView(itemCount: 1))),
                );
              }
              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
