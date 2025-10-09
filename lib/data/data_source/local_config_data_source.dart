import 'package:local_config/common/extension/map_extension.dart';
import 'package:local_config/core/storage/key_value_store.dart';
import 'package:local_config/data/util/key_namespace.dart';
import 'package:local_config/domain/data_source/config_data_source.dart';

class LocalConfigDataSource extends ConfigDataSource {
  final KeyNamespace _keyNamespace;

  final KeyValueStore _keyValueStore;

  LocalConfigDataSource({
    required KeyNamespace keyNamespace,
    required KeyValueStore keyValueStore,
  }) : _keyNamespace = keyNamespace,
       _keyValueStore = keyValueStore;

  @override
  Future<Map<String, String>> get all async {
    final all = await _keyValueStore.all;

    final internal = all
        .whereKey((key) => _keyNamespace.matches(key))
        .map(
          (key, value) => MapEntry(_keyNamespace.strip(key), value.toString()),
        );

    return internal;
  }

  @override
  Future<String?> get(String key) =>
      _keyValueStore.getString(_keyNamespace.apply(key));

  @override
  Future<void> set(String key, String value) =>
      _keyValueStore.setString(_keyNamespace.apply(key), value);

  @override
  Future<void> remove(String key) =>
      _keyValueStore.remove(_keyNamespace.apply(key));

  @override
  Future<void> clear() async {
    final existingKeys = (await all).keys;

    for (final key in existingKeys) {
      await remove(key);
    }
  }

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
