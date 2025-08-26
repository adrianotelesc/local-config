library local_config;

import 'package:flutter/widgets.dart' show Widget;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesAsync;
import 'package:local_config/data/data_source/shared_preferences_data_source.dart';
import 'package:local_config/data/repository/default_config_repository.dart';
import 'package:local_config/data/repository/dummy_config_repository.dart';
import 'package:local_config/domain/data_source/key_value_data_source.dart';
import 'package:local_config/domain/repository/config_repository.dart';
import 'package:local_config/common/extension/string_extension.dart';
import 'package:local_config/infra/service_locator/get_it_service_locator.dart';
import 'package:local_config/ui/screen/local_config_list_screen.dart';

class LocalConfig {
  static final instance = LocalConfig._();

  final _locator = GetItServiceLocator();

  LocalConfig._() {
    _locator.registerLazySingleton<ConfigRepository>(
      () => DummyConfigRepository(),
    );
  }

  Stream<Map<String, String>> get onConfigUpdated {
    final repo = _locator.locate<ConfigRepository>();
    return repo.configsStream.map((configs) {
      return configs.map((key, config) => MapEntry(key, config.value));
    });
  }

  void initialize({required Map<String, String> configs}) {
    _locator.registerFactory(
      () => SharedPreferencesAsync(),
    );
    _locator.registerFactory<KeyValueDataSource>(
      () => SharedPreferencesDataSource(
        sharedPreferencesAsync: _locator.locate(),
      ),
    );

    _locator.unregister<ConfigRepository>();
    _locator.registerLazySingleton<ConfigRepository>(
      () => DefaultConfigRepository(
        dataSource: _locator.locate(),
      )..populate(configs),
    );
  }

  bool? getBool(String key) {
    final repo = _locator.locate<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asBool;
  }

  int? getInt(String key) {
    final repo = _locator.locate<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asInt;
  }

  double? getDouble(String key) {
    final repo = _locator.locate<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asDouble;
  }

  String? getString(String key) {
    final repo = _locator.locate<ConfigRepository>();
    final config = repo.get(key);
    return config?.value;
  }

  Widget get screen => LocalConfigListScreen(locator: _locator);
}
