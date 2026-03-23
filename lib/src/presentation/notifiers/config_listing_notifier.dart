import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:local_config/src/common/extensions/string_extension.dart';
import 'package:local_config/src/domain/entities/local_config_value.dart';
import 'package:local_config/src/domain/repositories/local_config_repository.dart';

class ConfigListingNotifier extends ChangeNotifier {
  ConfigListingNotifier({
    required LocalConfigRepository configRepo,
  }) : _configRepo = configRepo {
    refresh();
    _configUpdateSub = _configRepo.onConfigUpdated.listen((update) {
      if (update.updatedKeys.isEmpty) return;
      refresh();
    });
  }

  final LocalConfigRepository _configRepo;

  StreamSubscription? _configUpdateSub;

  var _configs = <String, LocalConfigValue>{};
  Map<String, LocalConfigValue> get configs => UnmodifiableMapView(_configs);

  var _items = <MapEntry<String, LocalConfigValue>>[];
  List<MapEntry<String, LocalConfigValue>> get items => _items;

  var _showOnlyOverrides = false;
  bool get showOnlyOverrides => _showOnlyOverrides;
  set showOnlyOverrides(bool value) {
    if (value == _showOnlyOverrides) return;
    _showOnlyOverrides = value;
    _applyFilters();
    notifyListeners();
  }

  bool get hasOverrides => _configs.values.any((v) => v.hasOverride);

  var _terms = <String>{};
  Set<String> get terms => UnmodifiableSetView(_terms);

  @override
  void dispose() {
    _configUpdateSub?.cancel();
    _configUpdateSub = null;
    super.dispose();
  }

  void query(String query) {
    _terms = query.split(RegExp(r'\W+')).toSet();
    _applyFilters(query: query);
    notifyListeners();
  }

  void refresh() {
    _configs = _configRepo.configs;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters({String? query}) {
    _items =
        _configs.entries
            .where((entry) => _overrideFilter(entry) && _termFilter(entry))
            .toList();
  }

  bool _overrideFilter(MapEntry<String, LocalConfigValue> entry) =>
      !_showOnlyOverrides || entry.value.hasOverride;

  bool _termFilter(MapEntry<String, LocalConfigValue> entry) =>
      _terms.isEmpty ||
      _terms.every((term) {
        return "${entry.key} ${entry.value}".containsInsensitive(term);
      });

  LocalConfigValue? get(String key) => _configRepo.get(key);

  Future<void> set(String key, String value) => _configRepo.set(key, value);

  Future<void> reset(String key) => _configRepo.reset(key);

  Future<void> resetAll() => _configRepo.resetAll();
}
