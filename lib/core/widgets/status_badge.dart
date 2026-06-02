import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 11,
              color: color,
            ),
      ),
    );
  }

  static StatusBadge member(BuildContext context, String label) => StatusBadge(
        label: label,
        color: AppColors.accentGreen,
      );

  static StatusBadge visitor(BuildContext context, String label) => StatusBadge(
        label: label,
        color: AppColors.primary,
      );
}
