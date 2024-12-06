import 'package:local_config/preferences/preferences_delegate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesDelegate extends PreferencesDelegate {
  static const _keyPrefix = 'local_config:';

  final _preferences = SharedPreferencesAsync();

  @override
  Future<Map<String, String>> getAll() async {
    final all = await _preferences.getAll();
    final entries = all.entries.where((entry) {
      return entry.key.startsWith(_keyPrefix);
    }).map((entry) {
      return MapEntry<String, String>(
        entry.key.replaceAll(_keyPrefix, ''),
        entry.value.toString(),
      );
    });
    return Map<String, String>.fromEntries(entries);
  }

  @override
  Future<String?> getPreference(String key) async =>
      await _preferences.getString(_keyPrefix + key);

  @override
  Future<void> setPreference(String key, String value) async =>
      await _preferences.setString(_keyPrefix + key, value);

  @override
  Future<void> removePreference(String key) async {
    await _preferences.remove(key);
  }
}
