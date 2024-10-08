enum ConfigValueType {
  bool,
  int,
  double,
  string,
  json;
}

class ConfigValue {
  final String value;
  final ConfigValueType valueType;

  const ConfigValue({
    required this.value,
    required this.valueType,
  });
}
