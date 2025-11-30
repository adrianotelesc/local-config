part of '../local_config.dart';

final class LocalConfig {
  static const _namespace = 'local_config';

  static final instance = LocalConfig._();

  final _locator = GetItServiceLocator();

  LocalConfig._() {
    _locator.registerLazySingleton<ConfigRepository>(
      () => NoOpConfigRepository(),
    );
  }

  void initialize({
    required Map<String, dynamic> parameters,
    KeyValueService? keyValueService,
  }) {
    _locator
      ..registerFactory<KeyValueService>(
        () => NamespacedKeyValueService(
          namespace: KeyNamespace(namespace: _namespace),
          inner:
              keyValueService ??
              SharedPreferencesKeyValueService(
                sharedPreferences: SharedPreferencesAsync(),
              ),
        ),
      )
      ..registerFactory<KeyValueDataSource>(
        () => DefaultKeyValueDataSource(service: _locator.get()),
      )
      ..registerFactory<ConfigStore>(() => DefaultConfigStore())
      ..unregister<ConfigRepository>()
      ..registerLazySingleton<ConfigRepository>(
        () => DefaultConfigRepository(
          dataSource: _locator.get(),
          store: _locator.get(),
        )..populate(parameters),
      );
  }

  Widget get entrypoint {
    return Provider<ServiceLocator>(
      create: (_) => _locator,
      child: const LocalConfigEntrypoint(),
    );
  }

  Stream<Map<String, dynamic>> get onConfigUpdated {
    final repo = _locator.get<ConfigRepository>();
    return repo.configsStream.map((configs) {
      return configs.map((key, config) => MapEntry(key, config.value));
    });
  }

  bool? getBool(String key) {
    final repo = _locator.get<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asBoolOrNull;
  }

  double? getDouble(String key) {
    final repo = _locator.get<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asDoubleOrNull;
  }

  int? getInt(String key) {
    final repo = _locator.get<ConfigRepository>();
    final config = repo.get(key);
    return config?.value.asIntOrNull;
  }

  String? getString(String key) {
    final repo = _locator.get<ConfigRepository>();
    final config = repo.get(key);
    return config?.value;
  }
}
