library local_config;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_config/common/extension/string_extension.dart';
import 'package:local_config/core/di/service_locator.dart';
import 'package:local_config/core/storage/key_value_store.dart';
import 'package:local_config/data/data_source/default_config_data_source.dart';
import 'package:local_config/data/repository/default_config_repository.dart';
import 'package:local_config/data/repository/no_op_config_repository.dart';
import 'package:local_config/domain/data_source/config_data_source.dart';
import 'package:local_config/domain/repository/config_repository.dart';
import 'package:local_config/infra/di/get_it_service_locator.dart';
import 'package:local_config/infra/storage/namespaced_key_value_store.dart';
import 'package:local_config/infra/storage/secure_storage_key_value_store.dart';
import 'package:local_config/infra/storage/shared_preferences_key_value_store.dart';
import 'package:local_config/infra/util/key_namespace.dart';
import 'package:local_config/ui/local_config_entrypoint.dart';

class LocalConfig {
  static const _namespace = 'local_config';

  static final instance = LocalConfig._();

  final _serviceLocator = GetItServiceLocator();

  LocalConfig._() {
    _serviceLocator.registerLazySingleton<ConfigRepository>(
      () => NoOpConfigRepository(),
    );
  }

  void initialize({
    required Map<String, String> configs,
    bool isSecureStorageEnabled = false,
  }) {
    _serviceLocator
      ..registerFactory<KeyValueStore>(
        () => NamespacedKeyValueStore(
          keyNamespace: KeyNamespace(namespace: _namespace),
          innerStore: isSecureStorageEnabled
              ? SecureStorageKeyValueStore(
                  secureStorage: const FlutterSecureStorage(
                    aOptions: AndroidOptions(
                      encryptedSharedPreferences: true,
                    ),
                  ),
                )
              : SharedPreferencesKeyValueStore(
                  sharedPreferencesAsync: SharedPreferencesAsync(),
                ),
        ),
      )
      ..registerFactory<ConfigDataSource>(
        () => DefaultConfigDataSource(
          keyValueStore: _serviceLocator.get(),
        ),
      )
      ..unregister<ConfigRepository>()
      ..registerLazySingleton<ConfigRepository>(
        () => DefaultConfigRepository(
          dataSource: _serviceLocator.get(),
        )..populate(configs),
      );
  }

  Widget get entrypoint {
    return Provider<ServiceLocator>(
      create: (_) => _serviceLocator,
      child: const LocalConfigEntrypoint(),
    );
  }

  Stream<Map<String, String>> get onConfigUpdated {
    final repo = _serviceLocator.get<ConfigRepository>();
    return repo.configsStream.map((configs) {
      return configs.map((key, config) => MapEntry(key, config.value));
    });
  }

  bool? getBool(String key) {
    final repo = _serviceLocator.get<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asBoolOrNull;
  }

  double? getDouble(String key) {
    final repo = _serviceLocator.get<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asDoubleOrNull;
  }

  int? getInt(String key) {
    final repo = _serviceLocator.get<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asIntOrNull;
  }

  String? getString(String key) {
    final repo = _serviceLocator.get<ConfigRepository>();
    final config = repo.get(key);
    return config?.value;
  }
}
