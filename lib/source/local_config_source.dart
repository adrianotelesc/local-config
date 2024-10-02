abstract class LocalConfigSource {
  Future<String?> getConfig(String key);

  Future<void> setConfig(String key, String value);
}
