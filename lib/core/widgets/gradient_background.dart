import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.backgroundGradient
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.scaffoldLight,
                  AppColors.primary.withValues(alpha: 0.08),
                ],
              ),
      ),
      child: child,
    );
  }
}
