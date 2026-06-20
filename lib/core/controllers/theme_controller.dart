import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_pro_manager/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  ThemeController(this._prefs);

  static const _storageKey = 'theme_mode';

  final SharedPreferences _prefs;
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  bool get isLight => themeMode.value == ThemeMode.light;

  bool get isDark => themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    final saved = _prefs.getString(_storageKey);
    if (saved == 'dark') {
      themeMode.value = ThemeMode.dark;
    }
    _syncGetTheme();
  }

  void setLight() {
    themeMode.value = ThemeMode.light;
    Get.changeTheme(ThemeData.light());
    _prefs.setString(_storageKey, 'light');
    _syncGetTheme();
  }

  void setDark() {
    themeMode.value = ThemeMode.dark;
    Get.changeTheme(ThemeData.dark());
    _prefs.setString(_storageKey, 'dark');
    _syncGetTheme();
  }

  void toggleTheme() {
    if (isLight) {
      setDark();
    } else {
      setLight();
    }
  }

  void _syncGetTheme() {
    Get.changeTheme(isDark ? AppTheme.darkTheme : AppTheme.lightTheme);
  }
}
