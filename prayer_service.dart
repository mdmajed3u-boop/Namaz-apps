import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/prayer_time_model.dart';

class PrayerService {
  // Aladhan API - বিনামূল্যে নামাজের সময়সূচী API
  // calculation method 1 = University of Islamic Sciences, Karachi
  // (বাংলাদেশ ও দক্ষিণ এশিয়ার জন্য সাধারণত ব্যবহৃত হয়)
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  /// বর্তমান লোকেশন বের করা (GPS)
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('লোকেশন সার্ভিস বন্ধ আছে। অনুগ্রহ করে GPS চালু করুন।');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('লোকেশন পারমিশন দেওয়া হয়নি।');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'লোকেশন পারমিশন স্থায়ীভাবে বন্ধ করা আছে। সেটিংস থেকে চালু করুন।');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  /// অক্ষাংশ ও দ্রাঘিমাংশ দিয়ে আজকের নামাজের সময়সূচী আনা
  Future<PrayerTimeModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    int method = 1,
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.day}-${now.month}-${now.year}';

    final url = Uri.parse(
      '$_baseUrl/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=$method',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PrayerTimeModel.fromJson(data['data']);
    } else {
      throw Exception('নামাজের সময়সূচী আনতে সমস্যা হয়েছে।');
    }
  }

  /// পুরো মাসের নামাজের সময়সূচী আনা (ক্যালেন্ডার ভিউ এর জন্য)
  Future<List<PrayerTimeModel>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
    int method = 1,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/calendar/$year/$month?latitude=$latitude&longitude=$longitude&method=$method',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List days = data['data'];
      return days.map((d) => PrayerTimeModel.fromJson(d)).toList();
    } else {
      throw Exception('মাসিক সময়সূচী আনতে সমস্যা হয়েছে।');
    }
  }

  /// শহরের নাম দিয়ে নামাজের সময়সূচী আনা (ঐচ্ছিক পদ্ধতি)
  Future<PrayerTimeModel> getPrayerTimesByCity({
    required String city,
    required String country,
    int method = 1,
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.day}-${now.month}-${now.year}';

    final url = Uri.parse(
      '$_baseUrl/timingsByCity/$dateStr?city=$city&country=$country&method=$method',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PrayerTimeModel.fromJson(data['data']);
    } else {
      throw Exception('নামাজের সময়সূচী আনতে সমস্যা হয়েছে।');
    }
  }
}
