class PrayerTimeModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String hijriDate;
  final String gregorianDate;

  PrayerTimeModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.gregorianDate,
  });

  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'];
    final date = json['date'];

    String cleanTime(String time) {
      // "05:12 (+06)" এর মতো স্ট্রিং থেকে শুধু সময় বের করা
      return time.split(' ').first;
    }

    return PrayerTimeModel(
      fajr: cleanTime(timings['Fajr']),
      sunrise: cleanTime(timings['Sunrise']),
      dhuhr: cleanTime(timings['Dhuhr']),
      asr: cleanTime(timings['Asr']),
      maghrib: cleanTime(timings['Maghrib']),
      isha: cleanTime(timings['Isha']),
      hijriDate:
          '${date['hijri']['day']} ${date['hijri']['month']['en']} ${date['hijri']['year']}',
      gregorianDate: date['readable'],
    );
  }

  // নামাজের নাম ও সময়ের তালিকা (বাংলায়) পাওয়ার জন্য হেল্পার মেথড
  List<Map<String, String>> toPrayerList() {
    return [
      {'name': 'ফজর', 'time': fajr, 'key': 'fajr'},
      {'name': 'সূর্যোদয়', 'time': sunrise, 'key': 'sunrise'},
      {'name': 'যোহর', 'time': dhuhr, 'key': 'dhuhr'},
      {'name': 'আসর', 'time': asr, 'key': 'asr'},
      {'name': 'মাগরিব', 'time': maghrib, 'key': 'maghrib'},
      {'name': 'এশা', 'time': isha, 'key': 'isha'},
    ];
  }
}
