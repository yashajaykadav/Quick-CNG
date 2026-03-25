import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool isDarkMode;
  final bool notificationsEnabled;

  AppSettings({this.isDarkMode = false, this.notificationsEnabled = true});

  AppSettings copyWith({bool? isDarkMode, bool? notificationsEnabled}) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

// We use a Notifier (Riverpod 2.0) for better async initialization
class SettingsNotifier extends Notifier<AppSettings> {
  static const _darkKey = 'isDarkMode';
  static const _notifyKey = 'notificationsEnabled';

  @override
  AppSettings build() {
    // We will initialize with default values;
    // The actual disk loading happens in main.dart via an override or init.
    return AppSettings();
  }

  // Method to load data from disk
  void init(SharedPreferences prefs) {
    state = AppSettings(
      isDarkMode: prefs.getBool(_darkKey) ?? false,
      notificationsEnabled: prefs.getBool(_notifyKey) ?? true,
    );
  }

  void toggleDarkMode(bool value) async {
    state = state.copyWith(isDarkMode: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
  }

  void toggleNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifyKey, value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});
