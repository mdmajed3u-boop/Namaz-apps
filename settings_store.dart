import 'package:shared_preferences/shared_preferences.dart';

/// অ্যাপের সেটিংস সংরক্ষণ ও লোড করার জন্য হেল্পার ক্লাস
class SettingsStore {
  static const _keyDarkMode = 'dark_mode';
  static const _keyNotifications = 'notifications_on';
  static const _keyCalcMethod = 'calc_method';

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  static Future<bool> getNotificationsOn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifications) ?? true;
  }

  static Future<void> setNotificationsOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
  }

  static Future<int> getCalcMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCalcMethod) ?? 1; // ডিফল্ট: Karachi
  }

  static Future<void> setCalcMethod(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCalcMethod, value);
  }
}

/// হিসাব পদ্ধতির তালিকা (Aladhan API অনুযায়ী)
const Map<int, String> calculationMethods = {
  1: 'University of Islamic Sciences, Karachi',
  2: 'Islamic Society of North America (ISNA)',
  3: 'Muslim World League',
  4: 'Umm al-Qura, Makkah',
  5: 'Egyptian General Authority',
  8: 'Gulf Region',
  12: 'Union Organization Islamic de France',
};
