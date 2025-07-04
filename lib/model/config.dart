import 'package:local_config/extension/string_parsing_extension.dart';

class Config {
  final String value;

  ConfigType get type {
    if (value.asBool != null) return ConfigType.boolean;
    if (value.asDouble != null) return ConfigType.number;
    if (value.asJson != null) return ConfigType.json;
    return ConfigType.string;
  }

  const Config({required this.value});
}

enum ConfigType {
  boolean,
  number,
  string,
  json;

  bool get isText => this == ConfigType.string || this == ConfigType.json;
}
