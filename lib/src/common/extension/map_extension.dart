import 'dart:convert';

extension MapExtension<K, V> on Map<K, V> {
  Map<K, V> where(bool Function(K, V) test) => Map<K, V>.fromEntries(
    entries.where((entry) => test(entry.key, entry.value)),
  );

  List<(K, V)> toRecordList() =>
      entries.map((entry) => (entry.key, entry.value)).toList();

  bool anyValue(bool Function(V) test) => values.any((value) => test(value));

  Map<String, String> stringify() => map(
    (key, value) => MapEntry(key?.toString() ?? '', _stringifyValue(value)),
  ).where((key, value) => key.isNotEmpty);

  String _stringifyValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    if (value is Map || value is List) return jsonEncode(value);
    return value.toString();
  }
}
