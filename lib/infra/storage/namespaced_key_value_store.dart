import 'package:local_config/common/extension/map_extension.dart';
import 'package:local_config/core/storage/key_value_store.dart';
import 'package:local_config/infra/util/key_namespace.dart';

class NamespacedKeyValueStore implements KeyValueStore {
  final KeyNamespace _keyNamespace;

  final KeyValueStore _innerStore;

  NamespacedKeyValueStore({
    required KeyNamespace keyNamespace,
    required KeyValueStore innerStore,
  }) : _keyNamespace = keyNamespace,
       _innerStore = innerStore;

  @override
  Future<Map<String, Object?>> get all async {
    final all = await _innerStore.all;

    final namespaced = all
        .whereKey((key) => _keyNamespace.matches(key))
        .map(
          (key, value) => MapEntry(_keyNamespace.strip(key), value),
        );

    return namespaced;
  }

  @override
  Future<String?> getString(String key) =>
      _innerStore.getString(_keyNamespace.apply(key));

  @override
  Future<void> remove(String key) =>
      _innerStore.remove(_keyNamespace.apply(key));

  @override
  Future<void> setString(String key, String value) =>
      _innerStore.setString(_keyNamespace.apply(key), value);
}
