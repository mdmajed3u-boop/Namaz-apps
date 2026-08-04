import 'package:intl/intl.dart';

class TimeUtils {
  /// "05:12" ফরম্যাটের স্ট্রিং কে আজকের DateTime এ রূপান্তর করা
  static DateTime parseTimeToday(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// ২৪ ঘণ্টার ফরম্যাট থেকে ১২ ঘণ্টার (AM/PM সহ) ফরম্যাটে রূপান্তর
  static String to12HourFormat(String time24) {
    final dt = parseTimeToday(time24);
    return DateFormat('hh:mm a').format(dt);
  }

  /// পরবর্তী নামাজ কোনটি এবং তার বাকি সময় বের করা
  static Map<String, dynamic> getNextPrayer(
      List<Map<String, String>> prayerList) {
    final now = DateTime.now();

    // সূর্যোদয় বাদ দিয়ে শুধু ৫ ওয়াক্ত নামাজ বিবেচনা করা
    final prayers =
        prayerList.where((p) => p['key'] != 'sunrise').toList();

    for (var prayer in prayers) {
      final prayerTime = parseTimeToday(prayer['time']!);
      if (prayerTime.isAfter(now)) {
        final diff = prayerTime.difference(now);
        return {
          'name': prayer['name'],
          'time': prayer['time'],
          'remaining': diff,
        };
      }
    }

    // আজকের সব নামাজ শেষ হয়ে গেলে, আগামীকালের ফজর দেখানো
    final fajrTomorrow =
        parseTimeToday(prayers.first['time']!).add(const Duration(days: 1));
    return {
      'name': prayers.first['name'],
      'time': prayers.first['time'],
      'remaining': fajrTomorrow.difference(now),
    };
  }

  /// Duration কে "ঘ মি সে" বাংলা ফরম্যাটে দেখানো
  static String formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// বাংলা সংখ্যায় রূপান্তর (ঐচ্ছিক - সুন্দর দেখানোর জন্য)
  static String toBanglaDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bangla[i]);
    }
    return result;
  }
}
