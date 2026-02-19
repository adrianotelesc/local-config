import 'package:local_config/src/core/storage/key_value_store.dart';

class LocalConfigSettings {
  final KeyValueStore? keyValueStore;
  final List<String> keySegments;

  LocalConfigSettings({this.keyValueStore, this.keySegments = const []});
}
