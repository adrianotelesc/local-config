import 'dart:convert';

import 'package:local_config/src/core/storage/key_value_store.dart';
import 'package:local_config/src/data/data_source/key_value_data_source.dart';

class DefaultKeyValueDataSource extends KeyValueDataSource {
  final KeyValueStore _store;

  DefaultKeyValueDataSource({required KeyValueStore service})
    : _store = service;

  @override
  Future<Map<String, dynamic>> get all async {
    final all = await _store.all;
    return all.map((key, value) => MapEntry(key, TypeSerializer.encode(value)));
  }

  @override
  Future<void> clear() async {
    final existingKeys = (await all).keys;

    for (final key in existingKeys) {
      await remove(key);
    }
  }

  @override
  Future<dynamic> get(String key) async =>
      TypeSerializer.decode(await _store.getString(key));

  @override
  Future<void> prune(Set<String> retainedKeys) async {
    final existingKeys = (await all).keys;

    for (final key in existingKeys) {
      if (!retainedKeys.contains(key)) {
        await remove(key);
      }
    }
  }

  @override
  Future<void> remove(String key) => _store.remove(key);

  @override
  Future<void> set(String key, dynamic value) =>
      _store.setString(key, TypeSerializer.encode(value));
}

class TypeSerializer {
  static String encode(dynamic value) {
    return jsonEncode({'type': value.runtimeType.toString(), 'value': value});
  }

  static dynamic decode(String? jsonStr) {
    if (jsonStr == null) return null;

    final map = jsonDecode(jsonStr);
    final type = map['type'];
    final value = map['value'];

    switch (type) {
      case 'int':
        return value as int;
      case 'double':
        return (value as num).toDouble();
      case 'bool':
        return value as bool;
      case 'String':
        return value as String;
      case 'List':
        return List<dynamic>.from(value);
      case 'Map':
        return Map<String, dynamic>.from(value);
      default:
        return value;
    }
  }
}
