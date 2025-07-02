library local_config;

import 'dart:async';

import 'package:local_config/extension/string_parsing.dart';
import 'package:local_config/model/config.dart';
import 'package:flutter/material.dart';
import 'package:local_config/preferences/preferences_delegate.dart';
import 'package:local_config/preferences/shared_preferences_delegate.dart';
import 'package:local_config/screen/local_config_screen.dart';

class LocalConfig {
  LocalConfig._();

  static final instance = LocalConfig._();

  final PreferencesDelegate _preferencesDelegate = SharedPreferencesDelegate();

  final _configs = <String, Config>{};
  Map<String, Config> get configs => _configs;

  final _localConfigs = <String, Config>{};
  final _localConfigsStreamController = StreamController<Map<String, Config>>();

  Future<void> initialize({required Map<String, Config> configs}) async {
    _configs.addAll(configs);

    var configsInPreferences = await _preferencesDelegate.getAllPreferences();
    for (final key in configsInPreferences.keys) {
      if (!configs.containsKey(key)) {
        await _preferencesDelegate.removePreference(key);
      }
    }

    final localConfigs = <String, Config>{};
    for (final config in configsInPreferences.entries) {
      localConfigs[config.key] = Config(value: config.value);
    }
    _localConfigs.addAll(localConfigs);

    _localConfigsStreamController.add(_localConfigs);
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
    await _preferencesDelegate.setPreference(key, value);
  }

  Future<void> remove(String key) async {
    if (!_localConfigs.containsKey(key)) return;
    _localConfigs.remove(key);
    _localConfigsStreamController.add(_localConfigs);
    await _preferencesDelegate.removePreference(key);
  }

  Future<void> removeAll() async {
    _localConfigs.clear();
    _localConfigsStreamController.add(_localConfigs);
    await _preferencesDelegate.removeAllPreferences();
  }

  Widget getLocalConfigsScreen() => const LocalConfigScreen();

  Stream<Map<String, Config>> get localConfigsStream =>
      _localConfigsStreamController.stream;
}
