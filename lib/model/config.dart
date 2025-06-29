import 'package:local_config/extension/string_parsing.dart';

class Config {
  final String value;
  final ConfigType type;

  Config({required this.value}) : type = _inferType(value);

  static _inferType(String value) {
    if (value.asBool != null) return ConfigType.boolean;
    if (value.asInt != null) return ConfigType.integer;
    if (value.asDouble != null) return ConfigType.decimal;
    if (value.asJson != null) return ConfigType.json;
    return ConfigType.string;
  }
}

enum ConfigType {
  boolean,
  integer,
  decimal,
  string,
  json;

  bool get isText => this == ConfigType.string || this == ConfigType.json;
}
