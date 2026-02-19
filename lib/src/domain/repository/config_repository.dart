import 'package:local_config/src/domain/entity/local_config_update.dart';
import 'package:local_config/src/domain/entity/local_config_value.dart';

abstract class ConfigRepository {
  Map<String, LocalConfigValue> get values;

  Stream<LocalConfigUpdate> get onConfigUpdated;

  LocalConfigValue? get(String key);

  Future<void> populate(Map<String, String> defaultParameters);

  Future<void> remove(String key);

  Future<void> clear();

  Future<void> set(String key, String value);
}
