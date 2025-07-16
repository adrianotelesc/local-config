import 'dart:async';

import 'package:local_config/model/config.dart';
import 'package:local_config/storage/key_value_store.dart';

class ConfigRepository {
  final KeyValueStore _store;

  final _configs = <String, Config>{};

  final _controller = StreamController<Map<String, Config>>.broadcast();

  ConfigRepository({
    required KeyValueStore store,
  }) : _store = store;

  Map<String, Config> get configs => Map.unmodifiable(_configs);

  Stream<Map<String, Config>> get stream async* {
    yield configs;
    yield* _controller.stream;
  }

  Future<void> populate({
    required Map<String, String> all,
  }) async {
    final stored = await _store.all;
    _populateConfigs(all, stored);
    await _pruneStore(all, stored);
  }

  void _populateConfigs(
    Map<String, String> all,
    Map<String, String> stored,
  ) {
    _configs.addAll(
      all.map((key, value) {
        return MapEntry(
          key,
          Config(
            defaultValue: value,
            overriddenValue: stored[key],
          ),
        );
      }),
    );
    _controller.add(configs);
  }

  Future<void> _pruneStore(
    Map<String, String> all,
    Map<String, String> stored,
  ) async {
    final keysToRemove = stored.keys.where((key) {
      return !all.containsKey(key);
    });
    await Future.wait(keysToRemove.map(_store.remove));
  }

  Future<Config?> get(String key) async => _configs[key];

  Future<void> set(String key, String value) async {
    final changed = _changeConfig(key, value);
    if (!changed) return;

    await _store.set(key, value);
  }

  bool _changeConfig(String key, String? value) {
    if (!_configs.containsKey(key)) return false;

    _configs.update(key, (config) => config.copyWith(value));
    _controller.add(configs);
    return true;
  }

  Future<void> reset(String key) async {
    final changed = _changeConfig(key, null);
    if (!changed) return;

    await _store.remove(key);
  }

  Future<void> resetAll() async {
    _configs.updateAll((key, value) => value.copyWith(null));
    _controller.add(configs);

    await _store.clear();
  }
}
