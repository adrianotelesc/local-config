import 'package:local_config/storage/key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStore extends KeyValueStore {
  static const _namespace = 'local_config';

  final SharedPreferencesAsync _sharedPreferencesAsync;

  final String _packageName;

  SharedPreferencesStore({
    required SharedPreferencesAsync sharedPreferencesAsync,
    required String packageName,
  })  : _sharedPreferencesAsync = sharedPreferencesAsync,
        _packageName = packageName;

  String get _internalKeyPrefix => '$_packageName.$_namespace:';

  @override
  Future<Map<String, String>> get all async {
    final all = await _sharedPreferencesAsync.getAll();
    final internalEntries = all.entries
        .where((e) => _isInternalKey(e.key))
        .map((e) => MapEntry(_fromInternalKey(e.key), e.value.toString()));
    return Map<String, String>.fromEntries(internalEntries);
  }

  @override
  Future<String?> get(String key) {
    return _sharedPreferencesAsync.getString(_toInternalKey(key));
  }

  @override
  Future<void> set(String key, String value) {
    return _sharedPreferencesAsync.setString(_toInternalKey(key), value);
  }

  @override
  Future<void> remove(String key) {
    return _sharedPreferencesAsync.remove(_toInternalKey(key));
  }

  @override
  Future<void> clear() async {
    await Future.wait((await all).keys.map(remove));
  }

  bool _isInternalKey(String key) => key.startsWith(_internalKeyPrefix);

  String _toInternalKey(String key) => '$_internalKeyPrefix$key';

  String _fromInternalKey(String key) =>
      key.replaceFirst(_internalKeyPrefix, '');
}
