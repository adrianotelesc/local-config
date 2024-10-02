import 'package:firebase_local_config/source/local_config_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesConfigSource extends LocalConfigSource {
  static const keyPrefix = 'shared_prefs_config_source:';

  @override
  Future<String?> getConfig(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPrefix + key);
  }

  @override
  Future<void> setConfig(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPrefix + key, value);
  }
}
