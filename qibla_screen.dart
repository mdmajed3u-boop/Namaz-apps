import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  // কাবা শরীফের অক্ষাংশ ও দ্রাঘিমাংশ
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  double? _qiblaDirection;
  StreamSubscription<CompassEvent>? _compassSubscription;
  double? _heading;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _error = 'লোকেশন সার্ভিস বন্ধ আছে।');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _error = 'লোকেশন পারমিশন প্রয়োজন।');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final qibla = _calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      setState(() => _qiblaDirection = qibla);

      if (FlutterCompass.events == null) {
        setState(() => _error = 'এই ডিভাইসে কম্পাস সেন্সর নেই।');
        return;
      }

      _compassSubscription = FlutterCompass.events!.listen((event) {
        setState(() => _heading = event.heading);
      });
    } catch (e) {
      setState(() => _error = 'ত্রুটি: ${e.toString()}');
    }
  }

  /// দুইটি জিও-কোঅর্ডিনেট থেকে কিবলার দিক (ডিগ্রি) হিসাব করা
  double _calculateQiblaDirection(double lat, double lng) {
    final lat1 = lat * pi / 180;
    final lat2 = _kaabaLat * pi / 180;
    final deltaLng = (_kaabaLng - lng) * pi / 180;

    final y = sin(deltaLng) * cos(lat2);
    final x =
        cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);

    double bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('কিবলার দিক'),
      ),
      body: Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              )
            : _qiblaDirection == null || _heading == null
                ? const CircularProgressIndicator()
                : _buildCompass(),
      ),
    );
  }

  Widget _buildCompass() {
    // কম্পাস ঘুরিয়ে কিবলার দিক নির্দেশ করা
    final angle = ((_qiblaDirection! - _heading!) * pi / 180);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mosque, size: 50, color: Color(0xFF1B5E4F)),
        const SizedBox(height: 20),
        const Text(
          'মোবাইলকে সমতল রেখে ধরুন',
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: -(_heading! * pi / 180),
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: const Color(0xFF1B5E4F), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'N',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Transform.rotate(
                angle: angle,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_upward,
                        size: 60, color: Color(0xFFD4AF37)),
                    Icon(Icons.mosque, size: 30, color: Color(0xFF1B5E4F)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'কিবলা: ${_qiblaDirection!.toStringAsFixed(1)}°',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
