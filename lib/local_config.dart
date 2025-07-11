library local_config;

import 'dart:async';

import 'package:local_config/extension/string_parsing_extension.dart';
import 'package:local_config/model/config.dart';
import 'package:flutter/material.dart';
import 'package:local_config/storage/key_value_store.dart';
import 'package:local_config/storage/shared_preferences_store.dart';
import 'package:local_config/ui/screen/local_config_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalConfig {
  LocalConfig._();

  static final instance = LocalConfig._();

  late final KeyValueStore _keyValueStore;

  final _configs = <String, Config>{};
  Map<String, Config> get configs => _configs;

  final _localConfigs = <String, Config>{};
  final _localConfigsStreamController = StreamController<Map<String, Config>>();

  Future<void> initialize({required Map<String, Config> configs}) async {
    await _initializeKeyValueStore();

    _configs.addAll(configs);

    var configsInPreferences = await _keyValueStore.all;
    for (final key in configsInPreferences.keys) {
      if (!configs.containsKey(key)) {
        await _keyValueStore.remove(key);
      }
    }

    final localConfigs = <String, Config>{};
    for (final config in configsInPreferences.entries) {
      localConfigs[config.key] = Config(value: config.value);
    }
    _localConfigs.addAll(localConfigs);

    _localConfigsStreamController.add(_localConfigs);
  }

  Future<void> _initializeKeyValueStore() async {
    final sharedPreferencesAsync = SharedPreferencesAsync();
    final packageName = (await PackageInfo.fromPlatform()).packageName;
    _keyValueStore = SharedPreferencesStore(
      sharedPreferencesAsync: sharedPreferencesAsync,
      packageName: packageName,
    );
  }

  Future<bool?> getBool(String key) async {
    final config = await getString(key);
    return config?.asBool;
  }

  Future<int?> getInt(String key) async {
    final config = await getString(key);
    return config?.asInt;
  }

  Future<double?> getDouble(String key) async {
    final config = await getString(key);
    return config?.asDouble;
  }

  Future<String?> getString(String key) async => _localConfigs[key]?.value;

  Future<void> setBool(String key, bool value) async {
    setString(key, value.toString());
  }

  Future<void> setInt(String key, int value) async {
    setString(key, value.toString());
  }

  Future<void> setDouble(String key, double value) async {
    setString(key, value.toString());
  }

  Future<void> setString(String key, String value) async {
    _localConfigs[key] = Config(value: value);
    _localConfigsStreamController.add(_localConfigs);
    await _keyValueStore.set(key, value);
  }

  Future<void> remove(String key) async {
    if (!_localConfigs.containsKey(key)) return;
    _localConfigs.remove(key);
    _localConfigsStreamController.add(_localConfigs);
    await _keyValueStore.remove(key);
  }

  Future<void> removeAll() async {
    _localConfigs.clear();
    _localConfigsStreamController.add(_localConfigs);
    await _keyValueStore.clear();
  }

  Widget getLocalConfigsScreen() => const LocalConfigScreen();

  Stream<Map<String, Config>> get localConfigsStream =>
      _localConfigsStreamController.stream;
}
