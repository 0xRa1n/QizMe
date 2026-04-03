import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(Map<String, bool>) onBack;

  const SettingsPage({super.key, required this.onBack});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = false;
  bool _darkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _pushNotifications = prefs.getBool('pushNotifications') ?? false;
      _darkMode = (prefs.getString('appTheme') ?? 'light') == 'dark';
      _isLoading = false;
    });
  }

  void _updatePushNotifications(bool value) {
    setState(() {
      _pushNotifications = value;
    });
  }

  void _updateDarkMode(bool value) {
    setState(() {
      _darkMode = value;
    });
  }

  @override
  void dispose() {
    // This will be called when the widget is removed from the widget tree
    widget.onBack({
      'pushNotifications': _pushNotifications,
      'darkMode': _darkMode,
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          settingsRow(
            label: 'Push notifications',
            value: _pushNotifications,
            onChanged: _updatePushNotifications,
          ),
          const SizedBox(height: 10),
          settingsRow(
            label: 'Dark mode',
            value: _darkMode,
            onChanged: _updateDarkMode,
          ),
        ],
      ),
    );
  }

  Widget settingsRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.blue),
        ],
      ),
    );
  }
}
