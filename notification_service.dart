import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/prayer_time_model.dart';
import '../utils/time_utils.dart';

/// নামাজের সময় হলে নোটিফিকেশন (আজান রিমাইন্ডার) দেখানোর সার্ভিস
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // ডিভাইসের লোকাল টাইমজোন ব্যবহার করা হচ্ছে (নির্দিষ্ট টাইমজোন লুকআপ ছাড়া
    // সহজ পদ্ধতি - প্রোডাকশনে flutter_timezone প্যাকেজ দিয়ে সঠিক টাইমজোন
    // অটো-ডিটেক্ট করা ভালো)
    tz.setLocalLocation(tz.local);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    // Android 13+ এ নোটিফিকেশন পারমিশন চাওয়া
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// আজকের বাকি নামাজগুলোর জন্য নোটিফিকেশন শিডিউল করা।
  /// প্রতিদিন নতুন সময় আসার সাথে সাথে এটি আবার কল করে রিশিডিউল করতে হবে।
  static Future<void> scheduleTodayPrayers(PrayerTimeModel times) async {
    if (!_initialized) await init();

    // আগের সব শিডিউল করা নোটিফিকেশন বাতিল করা (ডুপ্লিকেট এড়াতে)
    await _plugin.cancelAll();

    final prayers = times
        .toPrayerList()
        .where((p) => p['key'] != 'sunrise') // সূর্যোদয়ে নোটিফিকেশন লাগবে না
        .toList();

    const androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'নামাজের সময়',
      channelDescription: 'নামাজের ওয়াক্ত হলে জানিয়ে দেয়',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    int id = 0;
    for (final prayer in prayers) {
      final time = TimeUtils.parseTimeToday(prayer['time']!);
      // অতীতের সময় হলে স্কিপ করা
      if (time.isBefore(DateTime.now())) continue;

      final scheduledDate = tz.TZDateTime.from(time, tz.local);

      await _plugin.zonedSchedule(
        id++,
        '${prayer['name']} এর সময় হয়েছে',
        'এখন ${prayer['name']} নামাজের ওয়াক্ত শুরু হয়েছে।',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
