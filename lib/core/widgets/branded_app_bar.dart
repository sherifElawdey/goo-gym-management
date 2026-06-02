import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';

class BrandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandedAppBar({
    super.key,
    required this.title,
    required this.gymName,
    this.actions,
  });

  final String title;
  final String gymName;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gymName,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontSize: 17)),
        ],
      ),
      actions: actions,
    );
  }
}
