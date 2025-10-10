import 'package:local_config/core/storage/key_value_store.dart';
import 'package:local_config/domain/data_source/config_data_source.dart';

class DefaultConfigDataSource extends ConfigDataSource {
  final KeyValueStore _store;

  DefaultConfigDataSource({
    required KeyValueStore keyValueStore,
  }) : _store = keyValueStore;

  @override
  Future<Map<String, String>> get all async {
    final all = await _store.all;

    return all.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }

  @override
  Future<void> clear() async {
    final existingKeys = (await all).keys;

    for (final key in existingKeys) {
      await remove(key);
    }
  }

  @override
  Future<String?> get(String key) => _store.getString(key);

  @override
  Future<void> prune(Set<String> retainedKeys) async {
    final existingKeys = (await all).keys;

    for (final key in existingKeys) {
      if (!retainedKeys.contains(key)) {
        await remove(key);
      }
    }
  }

  @override
  Future<void> remove(String key) => _store.remove(key);

  @override
  Future<void> set(String key, String value) => _store.setString(key, value);
}
