class ConfigValue {
  final String raw;
  final ConfigValueType type;

  const ConfigValue({
    required this.raw,
    required this.type,
  });

  bool? get asBool => bool.tryParse(raw);
  double? get asDouble => double.tryParse(raw);
  int? get asInt => int.tryParse(raw);
  String? get asString => raw;
}

enum ConfigValueType {
  boolType,
  intType,
  doubleType,
  stringType,
  jsonType;

  bool get isText => [stringType, jsonType].contains(this);
}
