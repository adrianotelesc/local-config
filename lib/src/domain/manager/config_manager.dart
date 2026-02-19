import 'package:local_config/src/domain/entity/local_config_value.dart';

abstract class ConfigManager {
  Map<String, LocalConfigValue> get configs;

  void populate(
    Map<String, dynamic> defaultParameters,
    Map<String, dynamic> overrideParameters,
  );

  LocalConfigValue? get(String key);

  LocalConfigValue update(String key, dynamic value);

  void updateAll(dynamic value);
}
