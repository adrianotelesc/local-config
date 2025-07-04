import 'package:local_config/storage/key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStore extends KeyValueStore {
  static const _keyPrefix = 'local_config:';

  final _sharedPreferences = SharedPreferencesAsync();

  @override
  Future<Map<String, String>> get all async {
    final all = await _sharedPreferences.getAll();
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
  Future<String?> get(String key) async =>
      await _sharedPreferences.getString(_keyPrefix + key);

  @override
  Future<void> set(String key, String value) async =>
      await _sharedPreferences.setString(_keyPrefix + key, value);

  @override
  Future<void> remove(String key) async {
    await _sharedPreferences.remove(_keyPrefix + key);
  }

  @override
  Future<void> clear() async {
    final preferences = await all;
    for (final key in preferences.keys) {
      remove(key);
    }
  }
}
