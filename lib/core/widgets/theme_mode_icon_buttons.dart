import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_pro_manager/core/controllers/theme_controller.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';

/// Single app-bar control that toggles light/dark theme.
class ThemeModeIconButtons extends StatelessWidget {
  const ThemeModeIconButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = Get.find<ThemeController>();

    return Obx(() {
      final isDark = controller.isDark;
      return IconButton(
        onPressed: controller.toggleTheme,
        icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
        tooltip: isDark ? l10n.themeLight : l10n.themeDark,
      );
    });
  }
}
