import 'package:shared_preferences/shared_preferences.dart';

/// Simple helper around [SharedPreferences] for session-related flags.
class SessionPreferences {
  static const _rememberMeKey = 'remember_me_enabled';

  const SessionPreferences._();

  static Future<bool> getRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  static Future<void> setRememberMeEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, isEnabled);
  }
}
