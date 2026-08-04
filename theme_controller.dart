import 'package:flutter/material.dart';
import 'settings_store.dart';

/// পুরো অ্যাপ জুড়ে থিম পরিবর্তন করার জন্য গ্লোবাল নোটিফায়ার
class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.light);

  static Future<void> loadSavedTheme() async {
    final isDark = await SettingsStore.getDarkMode();
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    await SettingsStore.setDarkMode(isDark);
  }
}
