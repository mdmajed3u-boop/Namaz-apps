import 'package:flutter/material.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_service.dart';
import '../utils/settings_store.dart';
import '../utils/time_utils.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final PrayerService _service = PrayerService();
  List<PrayerTimeModel>? _monthData;
  bool _isLoading = true;
  String? _error;
  DateTime _selectedMonth = DateTime.now();

  static const _banglaMonths = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
  ];

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final position = await _service.getCurrentLocation();
      final method = await SettingsStore.getCalcMethod();
      final data = await _service.getMonthlyPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
        year: _selectedMonth.year,
        month: _selectedMonth.month,
        method: method,
      );
      setState(() {
        _monthData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    });
    _loadMonth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('মাসিক ক্যালেন্ডার'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  '${_banglaMonths[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_error!, textAlign: TextAlign.center),
                        ),
                      )
                    : _buildTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (_monthData == null) return const SizedBox();
    final today = DateTime.now();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _monthData!.length,
      itemBuilder: (context, index) {
        final day = _monthData![index];
        final dayNumber = index + 1;
        final isToday = today.year == _selectedMonth.year &&
            today.month == _selectedMonth.month &&
            today.day == dayNumber;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isToday
                ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary, width: 1.2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$dayNumber ${_banglaMonths[_selectedMonth.month - 1]}${isToday ? ' • আজ' : ''}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isToday ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: day
                    .toPrayerList()
                    .where((p) => p['key'] != 'sunrise')
                    .map((p) => Text(
                          '${p['name']}: ${TimeUtils.to12HourFormat(p['time']!)}',
                          style: const TextStyle(fontSize: 12.5),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
