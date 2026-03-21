extension MapExtension<K, V> on Map<K, V> {
  Map<K, V> where(bool Function(K, V) test) => Map<K, V>.fromEntries(
    entries.where((entry) => test(entry.key, entry.value)),
  );

  List<(K, V)> toRecordList() =>
      entries.map((entry) => (entry.key, entry.value)).toList();
}
