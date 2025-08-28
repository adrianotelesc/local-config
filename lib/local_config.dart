library local_config;

import 'package:flutter/material.dart';
import 'package:local_config/core/service_locator/service_locator.dart';
import 'package:local_config/ui/local_config_navigator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesAsync;
import 'package:local_config/data/data_source/shared_preferences_data_source.dart';
import 'package:local_config/data/repository/default_config_repository.dart';
import 'package:local_config/data/repository/dummy_config_repository.dart';
import 'package:local_config/domain/data_source/key_value_data_source.dart';
import 'package:local_config/domain/repository/config_repository.dart';
import 'package:local_config/common/extension/string_extension.dart';
import 'package:local_config/infra/service_locator/get_it_service_locator.dart';

class LocalConfig {
  static final instance = LocalConfig._();

  final _serviceLocator = GetItServiceLocator();

  LocalConfig._() {
    _serviceLocator.registerLazySingleton<ConfigRepository>(
      () => DummyConfigRepository(),
    );
  }

  Stream<Map<String, String>> get onConfigUpdated {
    final repo = _serviceLocator.locate<ConfigRepository>();
    return repo.configsStream.map((configs) {
      return configs.map((key, config) => MapEntry(key, config.value));
    });
  }

  void initialize({required Map<String, String> configs}) {
    _serviceLocator.registerFactory(
      () => SharedPreferencesAsync(),
    );
    _serviceLocator.registerFactory<KeyValueDataSource>(
      () => SharedPreferencesDataSource(
        sharedPreferencesAsync: _serviceLocator.locate(),
      ),
    );

    _serviceLocator.unregister<ConfigRepository>();
    _serviceLocator.registerLazySingleton<ConfigRepository>(
      () => DefaultConfigRepository(
        dataSource: _serviceLocator.locate(),
      )..populate(configs),
    );
  }

  bool? getBool(String key) {
    final repo = _serviceLocator.locate<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asBool;
  }

  int? getInt(String key) {
    final repo = _serviceLocator.locate<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asInt;
  }

  double? getDouble(String key) {
    final repo = _serviceLocator.locate<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asDouble;
  }

  String? getString(String key) {
    final repo = _serviceLocator.locate<ConfigRepository>();
    final config = repo.get(key);
    return config?.value;
  }

  Widget get entrypoint {
    return Provider<ServiceLocator>(
      create: (_) => _serviceLocator,
      child: const LocalConfigNavigator(),
    );
  }
}
