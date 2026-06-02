import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/gradient_background.dart';
import 'package:gym_pro_manager/core/widgets/gradient_button.dart';
import 'package:gym_pro_manager/features/auth/presentation/cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    _BrandHeader(theme: theme, appName: l10n.appName),
                    const SizedBox(height: AppSpacing.xl),
                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.welcomeBack,
                              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(l10n.signInSubtitle, style: theme.textTheme.bodyMedium),
                            const SizedBox(height: AppSpacing.xl),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: l10n.email,
                                hintText: l10n.emailHint,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (value) =>
                                  value != null && value.contains('@') ? null : l10n.emailInvalid,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: l10n.password,
                                hintText: l10n.passwordHint,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscureText = !_obscureText),
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value != null && value.length >= 6 ? null : l10n.passwordMinLength,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(l10n.rememberMe, style: theme.textTheme.bodyMedium),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
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
                                  label: l10n.signIn,
                                  icon: Icons.login_rounded,
                                  loading: state is AuthLoadingState,
                                  onPressed: state is AuthLoadingState
                                      ? null
                                      : () {
                                          if (_formKey.currentState?.validate() != true) return;
                                          context.read<AuthCubit>().login(
                                                email: _emailController.text.trim(),
                                                password: _passwordController.text,
                                                rememberMe: _rememberMe,
                                              );
                                        },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(l10n.secureAdminAccess, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.theme,
    required this.appName,
  });

  final ThemeData theme;
  final String appName;

  static const _logoAsset = 'assets/images/goo_gym_logo.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          _logoAsset,
          width: 320,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          appName,
          style: theme.textTheme.bodyMedium?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
