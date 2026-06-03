import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/constants/auth_messages.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/widgets/app_bottom_sheet.dart';
import 'package:gym_pro_manager/core/widgets/gradient_button.dart';
import 'package:gym_pro_manager/features/auth/presentation/cubit/auth_cubit.dart';

class UnlockPasswordSheet extends StatefulWidget {
  const UnlockPasswordSheet({super.key});

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return AppBottomSheet.show<bool>(
      context: context,
      title: context.l10n.reenterPasswordTitle,
      subtitle: context.l10n.reenterPasswordSubtitle,
      child: const UnlockPasswordSheet(),
    );
  }

  @override
  State<UnlockPasswordSheet> createState() => _UnlockPasswordSheetState();
}

class _UnlockPasswordSheetState extends State<UnlockPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthCubit>().reauthenticateWithPassword(
            _passwordController.text,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = AuthMessages.fromError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: email,
            readOnly: true,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: l10n.email,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            textDirection: TextDirection.ltr,
            autofocus: true,
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
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: l10n.signIn,
            icon: Icons.lock_open_rounded,
            loading: _loading,
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
