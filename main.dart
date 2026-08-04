import 'package:flutter/material.dart';
import 'screens/main_nav_screen.dart';
import 'services/notification_service.dart';
import 'utils/theme_controller.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // সংরক্ষিত থিম (ডার্ক/লাইট) লোড করা
  await ThemeController.loadSavedTheme();

  // নোটিফিকেশন সিস্টেম চালু করা
  await NotificationService.init();

  runApp(const NamazApp());
}

class NamazApp extends StatelessWidget {
  const NamazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'নামাজের সময়সূচী',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: const MainNavScreen(),
        );
      },
    );
  }
}
