import 'dart:async';

import 'package:local_config/src/common/extensions/map_extension.dart';
import 'package:local_config/src/core/persistence/key_value_storage.dart';
import 'package:local_config/src/domain/entities/local_config_update.dart';
import 'package:local_config/src/domain/entities/local_config_value.dart';
import 'package:local_config/src/domain/repositories/local_config_repository.dart';

class LocalConfigRepositoryImpl implements LocalConfigRepository {
  final Map<String, LocalConfigValue> _all = {};

  final _controller = StreamController<LocalConfigUpdate>.broadcast();

  final KeyValueStorage _storage;

  LocalConfigRepositoryImpl({required KeyValueStorage storage})
    : _storage = storage;

  @override
  Map<String, LocalConfigValue> get all => _all;

  @override
  Stream<LocalConfigUpdate> get onConfigUpdated => _controller.stream;

  @override
  LocalConfigValue? get(String key) => _all[key];

  @override
  Future<void> setDefaults(Map<String, String> defaults) async {
    final overrides = await _storage.all;

    final retainedKeys =
        defaults
            .where((key, value) {
              return overrides.containsKey(key) && overrides[key] != value;
            })
            .keys
            .toSet();

    overrides.removeWhere((key, _) => !retainedKeys.contains(key));

    await _storage.prune(retainedKeys);

    _all
      ..clear()
      ..addAll(
        defaults.map((key, value) {
          return MapEntry(
            key,
            LocalConfigValue(
              type: LocalConfigType.infer(value),
              defaultValue: value,
              overrideValue: overrides[key],
            ),
          );
        }),
      );
  }

  @override
  Future<void> remove(String key) async {
    _all.update(key, (configValue) {
      return configValue.setOverride(null);
    });

    await _storage.remove(key);

    _controller.add(LocalConfigUpdate({key}));
  }

  @override
  Future<void> clear() async {
    _all.updateAll((_, configValue) {
      return configValue.setOverride(null);
    });

    await _storage.clear();

    _controller.add(LocalConfigUpdate({..._all.keys}));
  }

  @override
  Future<void> set(String key, String value) async {
    final updated = _all.update(key, (configValue) {
      return configValue.setOverride(value);
    });

    if (updated.hasOverride) {
      await _storage.setString(key, value);
    } else {
      await _storage.remove(key);
    }

    _controller.add(LocalConfigUpdate({key}));
  }
}
