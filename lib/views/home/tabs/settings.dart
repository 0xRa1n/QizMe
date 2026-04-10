import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qizme/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  final Function(Map<String, bool>) onBack;
  // Add parameters to accept the theme state and callback from the parent.
  final bool initialDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsPage({
    super.key,
    required this.onBack,
    required this.initialDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Current values that the user can change
  late bool _pushNotification;
  late bool _currentDarkMode;
  late String _email; // Variable to hold the user's email

  // Initial values loaded from storage
  late bool _initialPushNotification;
  late bool _initialDarkMode;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // This lifecycle method is called when the parent widget rebuilds
  // and provides new properties to this widget.
  @override
  void didUpdateWidget(SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the dark mode from the parent changes, update our current state.
    if (widget.initialDarkMode != oldWidget.initialDarkMode) {
      setState(() {
        _currentDarkMode = widget.initialDarkMode;
      });
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    // Load the user's email
    _email =
        prefs.getString('email') ??
        ''; // Load email, provide a default empty string

    // Store the initial values when the page loads
    _initialPushNotification = prefs.getBool('pushNotification') ?? false;
    _initialDarkMode = widget.initialDarkMode;

    // Set the current values to be the same as the initial ones
    setState(() {
      _pushNotification = _initialPushNotification;
      _currentDarkMode = _initialDarkMode;
      _isLoading = false;
    });
  }

  void _updatePushNotification(bool value) {
    setState(() {
      _pushNotification = value;
    });
  }

  // This method now only calls the parent's callback.
  // The state update is handled by didUpdateWidget.
  void _updateDarkMode(bool value) {
    widget.onThemeChanged(value);
  }

  @override
  void dispose() {
    // Check if the final values are different from the initial values
    final bool pushNotificationChanged =
        _pushNotification != _initialPushNotification;
    final bool darkModeChanged = _currentDarkMode != _initialDarkMode;
    final bool hasChanged = pushNotificationChanged || darkModeChanged;

    // Only call the onBack callback if a change was made
    if (hasChanged) {
      widget.onBack({
        'pushNotification': _pushNotification,
        'darkMode': _currentDarkMode,
      });

      // now we will save this to shared preferences so that it persists across app restarts
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('pushNotification', _pushNotification);
        prefs.setBool('darkMode', _currentDarkMode);
      });

      // and also for the endpoint to update the user preferences in the backend, we can call the service here as well
      AuthService.updateUserPreferences(
        email: _email, // Use the loaded email here
        darkMode: _currentDarkMode,
        pushNotification: _pushNotification,
      );
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
            value: _pushNotification,
            onChanged: _updatePushNotification,
            isDark: _currentDarkMode,
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            label: 'Dark mode',
            value: _currentDarkMode,
            onChanged: _updateDarkMode,
            isDark: _currentDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    // Apply styles based on the theme
    final Color containerColor = isDark
        ? const Color.fromARGB(255, 45, 106, 79)
        : Colors.grey[200]!;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final FontWeight fontWeight = isDark ? FontWeight.w600 : FontWeight.w500;
    final BoxBorder? border = isDark
        ? null
        : Border.all(color: Colors.black12, width: 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(
          15,
        ), // Use border radius from example
        border: border, // Apply border only in light mode
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: fontWeight, // Apply font weight from example
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.blue),
        ],
      ),
    );
  }
}
