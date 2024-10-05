abstract class PreferencesDelegate {
  Future<Map<String, String>> getAll();

  Future<String?> getPreference(String key);

  Future<void> setPreference(String key, String value);

  Future<void> removePreference(String key);
}
