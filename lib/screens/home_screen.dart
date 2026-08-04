import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_service.dart';
import '../services/notification_service.dart';
import '../utils/settings_store.dart';
import '../utils/time_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerService _prayerService = PrayerService();

  PrayerTimeModel? _prayerTimes;
  bool _isLoading = true;
  String? _errorMessage;
  String _locationName = 'লোকেশন খোঁজা হচ্ছে...';

  Timer? _timer;
  Map<String, dynamic>? _nextPrayer;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _prayerService.getCurrentLocation();
      final method = await SettingsStore.getCalcMethod();
      final times = await _prayerService.getPrayerTimesByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        method: method,
      );

      setState(() {
        _prayerTimes = times;
        _locationName =
            'অক্ষাংশ: ${position.latitude.toStringAsFixed(2)}, দ্রাঘিমাংশ: ${position.longitude.toStringAsFixed(2)}';
        _isLoading = false;
        _updateNextPrayer();
      });

      // প্রতি সেকেন্ডে কাউন্টডাউন আপডেট করা
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateNextPrayer();
      });

      // নোটিফিকেশন চালু থাকলে আজকের বাকি নামাজগুলোর জন্য রিমাইন্ডার শিডিউল করা
      final notificationsOn = await SettingsStore.getNotificationsOn();
      if (notificationsOn) {
        await NotificationService.scheduleTodayPrayers(times);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _updateNextPrayer() {
    if (_prayerTimes == null) return;
    setState(() {
      _nextPrayer = TimeUtils.getNextPrayer(_prayerTimes!.toPrayerList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPrayerTimes,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorView()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return ListView(
      children: [
        const SizedBox(height: 100),
        const Icon(Icons.location_off, size: 60, color: Colors.grey),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: _loadPrayerTimes,
            icon: const Icon(Icons.refresh),
            label: const Text('আবার চেষ্টা করুন'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E4F),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // হেডার
        const Text(
          'নামাজের সময়সূচী',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(today, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        if (_prayerTimes != null)
          Text(_prayerTimes!.hijriDate,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 20),

        // পরবর্তী নামাজ কার্ড
        if (_nextPrayer != null) _buildNextPrayerCard(),

        const SizedBox(height: 24),
        const Text(
          'আজকের নামাজের সময়',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // নামাজের তালিকা
        if (_prayerTimes != null)
          ..._prayerTimes!.toPrayerList().map((p) => _buildPrayerTile(p)),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNextPrayerCard() {
    final remaining = _nextPrayer!['remaining'] as Duration;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E4F), Color(0xFF2E8B6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E4F).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('পরবর্তী নামাজ',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            _nextPrayer!['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            TimeUtils.to12HourFormat(_nextPrayer!['time']),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                'বাকি সময়: ${TimeUtils.formatDuration(remaining)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTile(Map<String, String> prayer) {
    final isNext = _nextPrayer != null && _nextPrayer!['name'] == prayer['name'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isNext
            ? const Color(0xFF1B5E4F).withOpacity(0.12)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isNext
            ? Border.all(color: const Color(0xFF1B5E4F), width: 1.4)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _iconForPrayer(prayer['key']!),
                color: const Color(0xFF1B5E4F),
              ),
              const SizedBox(width: 14),
              Text(
                prayer['name']!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            TimeUtils.to12HourFormat(prayer['time']!),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
              color: isNext ? const Color(0xFF1B5E4F) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForPrayer(String key) {
    switch (key) {
      case 'fajr':
        return Icons.nightlight_round;
      case 'sunrise':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.wb_sunny;
      case 'maghrib':
        return Icons.wb_twilight;
      case 'isha':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}
