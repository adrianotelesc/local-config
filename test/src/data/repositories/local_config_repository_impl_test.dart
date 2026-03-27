import 'package:flutter_test/flutter_test.dart';
import 'package:local_config/src/core/persistence/key_value_storage.dart';
import 'package:local_config/src/data/repositories/local_config_repository_impl.dart';
import 'package:local_config/src/domain/entities/local_config_update.dart';

void main() {
  late KeyValueStorage storage;
  late LocalConfigRepositoryImpl repo;

  setUp(() {
    storage = FakeKeyValueStorage();
    repo = LocalConfigRepositoryImpl(storage: storage);
  });

  group('setDefaults', () {
    test('should initialize configs with default values', () async {
      await repo.setDefaults({'a': '1', 'b': '2'});

      expect(repo.configs.keys, {'a', 'b'});
      expect(repo.get('a')?.asString, '1');
      expect(repo.get('b')?.asString, '2');
    });

    test('should apply overrides when present in storage', () async {
      await storage.setString('a', '10');

      await repo.setDefaults({'a': '1'});

      expect(repo.get('a')?.asString, '10');
      expect(repo.get('a')?.hasOverride, isTrue);
    });

    test('should ignore overrides equal to default', () async {
      await storage.setString('a', '1');

      await repo.setDefaults({'a': '1'});

      expect(repo.get('a')?.asString, '1');
      expect(repo.get('a')?.hasOverride, isFalse);
    });

    test('should prune keys not present in defaults', () async {
      await storage.setString('obsolete', 'value');

      await repo.setDefaults({'a': '1'});

      expect((await storage.all).containsKey('obsolete'), isFalse);
      expect(repo.configs.containsKey('obsolete'), isFalse);
    });
  });

  group('get', () {
    test('should return null when key does not exist', () {
      expect(repo.get('unknown'), isNull);
    });
  });

  group('set', () {
    test(
      'should update override and persist when value differs from default',
      () async {
        await repo.setDefaults({'a': '1'});

        await repo.set('a', '2');

        expect(repo.get('a')?.asString, '2');
        expect(await storage.all, {'a': '2'});
      },
    );

    test('should remove override when value equals default', () async {
      await repo.setDefaults({'a': '1'});

      await repo.set('a', '2');
      await repo.set('a', '1');

      expect(repo.get('a')?.hasOverride, isFalse);
      expect((await storage.all).containsKey('a'), isFalse);
    });

    test('should emit update event when value changes', () async {
      await repo.setDefaults({'a': '1'});

      expectLater(
        repo.onConfigUpdated,
        emits(
          predicate<LocalConfigUpdate>(
            (e) => e.updatedKeys.contains('a'),
          ),
        ),
      );

      await repo.set('a', '2');
    });
  });

  group('reset', () {
    test('should remove override and restore default value', () async {
      await repo.setDefaults({'a': '1'});
      await repo.set('a', '2');

      await repo.reset('a');

      expect(repo.get('a')?.asString, '1');
      expect((await storage.all).containsKey('a'), isFalse);
    });

    test('should emit update event on reset', () async {
      await repo.setDefaults({'a': '1', 'b': '2'});
      await repo.set('a', '2');
      await repo.set('b', '3');

      expectLater(
        repo.onConfigUpdated,
        emits(
          predicate<LocalConfigUpdate>(
            (e) => e.updatedKeys.contains('a'),
          ),
        ),
      );

      await repo.reset('a');
    });
  });

  group('resetAll', () {
    test('should clear all overrides and restore defaults', () async {
      await repo.setDefaults({'a': '1', 'b': '2'});
      await repo.set('a', '10');
      await repo.set('b', '20');

      await repo.resetAll();

      expect(repo.get('a')?.asString, '1');
      expect(repo.get('b')?.asString, '2');
      expect(await storage.all, isEmpty);
    });

    test('should emit update event with all keys', () async {
      await repo.setDefaults({'a': '1', 'b': '2'});

      expectLater(
        repo.onConfigUpdated,
        emits(
          predicate<LocalConfigUpdate>(
            (e) => e.updatedKeys.containsAll({'a', 'b'}),
          ),
        ),
      );

      await repo.resetAll();
    });
  });
}

class FakeKeyValueStorage implements KeyValueStorage {
  final Map<String, String> _store = {};

  @override
  Future<Map<String, String>> get all async => Map.from(_store);

  @override
  Future<void> setString(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<void> prune(Set<String> keysToKeep) async {
    _store.removeWhere((key, _) => !keysToKeep.contains(key));
  }

  @override
  Future<String?> getString(String key) async => _store[key];
}
