import 'package:local_config/domain/model/config.dart';
import 'package:local_config/domain/repository/config_repository.dart';

class DummyConfigRepository implements ConfigRepository {
  @override
  Map<String, Config> get configs => {};

  @override
  Stream<Map<String, Config>> get configsStream => const Stream.empty();

  @override
  Config? get(String key) => null;

  @override
  Future<void> populate(Map<String, String> configs) async {}

  @override
  Future<void> reset(String key) async {}

  @override
  Future<void> resetAll() async {}

  @override
  Future<void> set(String key, String value) async {}
}
