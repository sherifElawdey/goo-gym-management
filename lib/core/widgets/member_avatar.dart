import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.name, this.size = 44});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primaryLight.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
