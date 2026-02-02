extension MapExtension<K1, V1> on Map<K1, V1> {
  Map<K1, V1> where(bool Function(K1, V1) test) => Map<K1, V1>.fromEntries(
    entries.where((entry) => test(entry.key, entry.value)),
  );

  List<(K1, V1)> toRecordList() =>
      entries.map((entry) => (entry.key, entry.value)).toList();

  bool anyValue(bool Function(V1) test) => values.any((value) => test(value));

  Map<K1, V2> mapValues<V2>(V2 Function(V1) convert) =>
      map((key, value) => MapEntry(key, convert(value)));

  Map<K2, V1> mapKeys<K2>(K2 Function(K1) convert) =>
      map((key, value) => MapEntry(convert(key), value));
}
