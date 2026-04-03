import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(Map<String, bool>) onBack;

  const SettingsPage({super.key, required this.onBack});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Current values that the user can change
  late bool _pushNotification;
  late bool _darkMode;

  // Initial values loaded from storage
  late bool _initialPushNotification;
  late bool _initialDarkMode;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    // Load the initial values
    _initialPushNotification = prefs.getBool('pushNotification') ?? false;
    _initialDarkMode = prefs.getBool("darkMode") ?? false;

    // Set the current values to be the same as the initial ones
    setState(() {
      _pushNotification = _initialPushNotification;
      _darkMode = _initialDarkMode;
      _isLoading = false;
    });
  }

  void _updatePushNotification(bool value) {
    setState(() {
      _pushNotification = value;
    });
  }

  void _updateDarkMode(bool value) {
    setState(() {
      _darkMode = value;
    });
  }

  @override
  void dispose() {
    // Check if the current values are different from the initial values
    final bool hasChanged =
        _pushNotification != _initialPushNotification ||
        _darkMode != _initialDarkMode;

    // Only call the onBack callback if a change was made
    if (hasChanged) {
      widget.onBack({
        'pushNotification': _pushNotification,
        'darkMode': _darkMode,
      });
    }
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
          _buildSettingItem(
            label: 'Push notifications',
            value:
                _pushNotification, // this automatically sets the value of the switch
            onChanged: _updatePushNotification,
          ),
          const SizedBox(height: 10),
          _buildSettingItem(
            label: 'Dark mode',
            value: _darkMode, // this automatically sets the value of the switch
            onChanged: _updateDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
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
