class KeyNamespace {
  final String _namespace;

  final String _separator;

  KeyNamespace({
    required String namespace,
    String separator = ':',
  }) : assert(namespace.isNotEmpty, 'namespace cannot be empty'),
       assert(separator.isNotEmpty, 'separator cannot be empty'),
       _separator = separator,
       _namespace = namespace;

  get _namespacedKeyPrefix => '$_namespace$_separator';

  bool matches(String key) => key.startsWith(_namespacedKeyPrefix);

  String apply(String key) => '$_namespacedKeyPrefix$key';

  String strip(String key) => key.replaceFirst(_namespacedKeyPrefix, '');
}
