import 'package:flutter/material.dart';
import '../utils/settings_store.dart';
import '../utils/theme_controller.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDark = false;
  bool _notificationsOn = true;
  int _calcMethod = 1;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dark = await SettingsStore.getDarkMode();
    final notif = await SettingsStore.getNotificationsOn();
    final method = await SettingsStore.getCalcMethod();
    setState(() {
      _isDark = dark;
      _notificationsOn = notif;
      _calcMethod = method;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('সেটিংস')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('চেহারা'),
          _buildSwitchTile(
            title: 'ডার্ক মোড',
            subtitle: 'অ্যাপের থিম গাঢ় রঙে পরিবর্তন করুন',
            icon: Icons.dark_mode_outlined,
            value: _isDark,
            onChanged: (val) async {
              setState(() => _isDark = val);
              await ThemeController.toggleTheme(val);
            },
          ),
          const SizedBox(height: 20),
          _sectionTitle('নোটিফিকেশন'),
          _buildSwitchTile(
            title: 'আজান রিমাইন্ডার',
            subtitle: 'নামাজের ওয়াক্ত হলে নোটিফিকেশন পাঠানো হবে',
            icon: Icons.notifications_active_outlined,
            value: _notificationsOn,
            onChanged: (val) async {
              setState(() => _notificationsOn = val);
              await SettingsStore.setNotificationsOn(val);
              if (!val) {
                await NotificationService.cancelAll();
              }
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'নোট: অ্যাপ চালু করার সময় বাকি থাকা ওয়াক্তগুলোর জন্য নোটিফিকেশন শিডিউল হয়। '
              'ব্যাকগ্রাউন্ডে প্রতিদিন স্বয়ংক্রিয়ভাবে রিশিডিউল করতে চাইলে workmanager প্যাকেজ যোগ করা যেতে পারে।',
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).hintColor),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('হিসাব পদ্ধতি (Calculation Method)'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _calcMethod,
                isExpanded: true,
                items: calculationMethods.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value,
                              style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (val) async {
                  if (val == null) return;
                  setState(() => _calcMethod = val);
                  await SettingsStore.setCalcMethod(val);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'পরিবর্তন প্রয়োগ করতে হোম স্ক্রিনে রিফ্রেশ করুন।'),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('অ্যাপ সম্পর্কে'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('নামাজের সময়সূচী অ্যাপ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('সংস্করণ ১.০.০', style: TextStyle(fontSize: 13)),
                SizedBox(height: 8),
                Text(
                  'ডেটা সোর্স: Aladhan Prayer Times API',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        secondary: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
