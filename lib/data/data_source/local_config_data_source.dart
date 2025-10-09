import 'package:local_config/common/extension/map_extension.dart';
import 'package:local_config/core/storage/key_value_store.dart';
import 'package:local_config/domain/data_source/config_data_source.dart';

class LocalConfigDataSource extends ConfigDataSource {
  static const _namespace = 'local_config';

  static const _namespacedKeyPrefix = '$_namespace:';

  final KeyValueStore _keyValueStore;

  LocalConfigDataSource({
    required KeyValueStore keyValueStore,
  }) : _keyValueStore = keyValueStore;

  @override
  Future<Map<String, String>> get all async {
    final all = await _keyValueStore.all;

    final internal = all
        .whereKey((key) => _isNamespacedKey(key)) //
        .map(
          (key, value) => MapEntry(_fromNamespacedKey(key), value.toString()),
        );

    return internal;
  }

  bool _isNamespacedKey(String key) => key.startsWith(_namespacedKeyPrefix);

  String _fromNamespacedKey(String key) =>
      key.replaceFirst(_namespacedKeyPrefix, '');

  @override
  Future<String?> get(String key) =>
      _keyValueStore.getString(_toNamespacedKey(key));

  String _toNamespacedKey(String key) => '$_namespacedKeyPrefix$key';

  @override
  Future<void> set(String key, String value) =>
      _keyValueStore.setString(_toNamespacedKey(key), value);

  @override
  Future<void> remove(String key) =>
      _keyValueStore.remove(_toNamespacedKey(key));

  @override
  Future<void> clear() async => Future.wait((await all).keys.map(remove));

  @override
  Future<void> prune(Set<String> retainedKeys) async {
    final existingKeys = (await all).keys;

    for (final key in existingKeys) {
      if (!retainedKeys.contains(key)) {
        await remove(key);
      }
    }
  }
}
