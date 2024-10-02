library firebase_local_config;

import 'package:firebase_local_config/source/local_config_source.dart';
import 'package:firebase_local_config/source/shared_preferences_config_source.dart';
import 'package:flutter/material.dart';

class FirebaseLocalConfig {
  FirebaseLocalConfig._();

  static final instance = FirebaseLocalConfig._();

  final LocalConfigSource _source = SharedPreferencesConfigSource();

  Map<String, String> _configs = {};

  Future<void> setConfigs(Map<String, String> configs) async {
    _configs = configs;
  }

  Future<bool?> getBool(String key) async {
    final config = await _source.getConfig(key);
    if (config == null) return null;

    return bool.tryParse(config);
  }

  Future<int?> getInt(String key) async {
    final config = await _source.getConfig(key);
    if (config == null) return null;

    return int.tryParse(config);
  }

  Future<double?> getDouble(String key) async {
    final config = await _source.getConfig(key);
    if (config == null) return null;

    return double.tryParse(config);
  }

  Future<String?> getString(String key) async {
    return await _source.getConfig(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _source.setConfig(key, value.toString());
  }

  Future<void> setInt(String key, int value) async {
    await _source.setConfig(key, value.toString());
  }

  Future<void> setDouble(String key, double value) async {
    await _source.setConfig(key, value.toString());
  }

  Future<void> setString(String key, String value) async {
    await _source.setConfig(key, value.toString());
  }

  Widget getSettingsScreen() {
    final localConfigs = _configs.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Local Config'),
      ),
      body: ListView.builder(
        itemCount: localConfigs.length,
        itemBuilder: (context, index) {
          final entry = localConfigs[index];

          String type = 'String';
          if (bool.tryParse(entry.value) != null) {
            type = 'bool';
          } else if (int.tryParse(entry.value) != null) {
            type = 'int';
          } else if (double.tryParse(entry.value) != null) {
            type = 'double';
          }

          return InkWell(
            child: ListTile(
              title: Text(entry.key),
              subtitle: Text(type),
              trailing: Text(entry.value),
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}
