import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_config/data/data_source/local_config_data_source.dart';
import 'package:local_config/core/storage/key_value_store.dart';

class MockKeyValueStore extends Mock implements KeyValueStore {}

void main() {
  late MockKeyValueStore mockKeyValueStore;
  late LocalConfigDataSource dataSource;

  setUp(() {
    mockKeyValueStore = MockKeyValueStore();
    dataSource = LocalConfigDataSource(keyValueStore: mockKeyValueStore);
  });

  group('LocalConfigDataSource.all', () {
    test('returns only namespaced keys with prefix removed', () async {
      const allData = {
        'local_config:foo': 'bar',
        'other:key': 'value',
      };

      when(() => mockKeyValueStore.all).thenAnswer((_) async => allData);

      final result = await dataSource.all;

      expect(result.length, 1);
      expect(result['foo'], 'bar');
      expect(result.containsKey('other:key'), isFalse);
    });

    test('returns empty map if no namespaced keys', () async {
      const allData = {'other:key': 'value'};

      when(() => mockKeyValueStore.all).thenAnswer((_) async => allData);

      final result = await dataSource.all;

      expect(result, isEmpty);
    });
  });

  group('LocalConfigDataSource.get', () {
    test('returns value for namespaced key', () async {
      const key = 'foo';
      const value = 'bar';

      when(
        () => mockKeyValueStore.getString('local_config:foo'),
      ).thenAnswer((_) async => value);

      final result = await dataSource.get(key);

      expect(result, value);
      verify(() => mockKeyValueStore.getString('local_config:foo')).called(1);
    });
  });

  group('LocalConfigDataSource.set', () {
    test('sets value for namespaced key', () async {
      const key = 'foo';
      const value = 'bar';

      when(
        () => mockKeyValueStore.setString('local_config:foo', value),
      ).thenAnswer((_) async {});

      await dataSource.set(key, value);

      verify(
        () => mockKeyValueStore.setString('local_config:foo', value),
      ).called(1);
    });
  });

  group('LocalConfigDataSource.remove', () {
    test('removes namespaced key', () async {
      const key = 'foo';

      when(
        () => mockKeyValueStore.remove('local_config:foo'),
      ).thenAnswer((_) async {});

      await dataSource.remove(key);

      verify(() => mockKeyValueStore.remove('local_config:foo')).called(1);
    });
  });

  group('LocalConfigDataSource.clear', () {
    test('removes all namespaced keys', () async {
      const allData = {
        'local_config:a': '1',
        'local_config:b': '2',
        'other:key': 'x',
      };

      when(() => mockKeyValueStore.all).thenAnswer((_) async => allData);
      when(() => mockKeyValueStore.remove(any())).thenAnswer((_) async {});

      await dataSource.clear();

      verify(() => mockKeyValueStore.remove('local_config:a')).called(1);
      verify(() => mockKeyValueStore.remove('local_config:b')).called(1);
      verifyNever(() => mockKeyValueStore.remove('other:key'));
    });
  });

  group('LocalConfigDataSource.prune', () {
    test('removes keys not in retainedKeys', () async {
      const allData = {
        'local_config:a': '1',
        'local_config:b': '2',
        'local_config:c': '3',
      };
      const retainedKeys = {'b', 'c'};

      when(() => mockKeyValueStore.all).thenAnswer((_) async => allData);
      when(() => mockKeyValueStore.remove(any())).thenAnswer((_) async {});

      await dataSource.prune(retainedKeys);

      verify(() => mockKeyValueStore.remove('local_config:a')).called(1);
      verifyNever(() => mockKeyValueStore.remove('local_config:b'));
      verifyNever(() => mockKeyValueStore.remove('local_config:c'));
    });

    test('does not remove anything if all keys are retained', () async {
      const allData = {
        'local_config:a': '1',
        'local_config:b': '2',
      };
      const retainedKeys = {'a', 'b'};

      when(() => mockKeyValueStore.all).thenAnswer((_) async => allData);
      when(() => mockKeyValueStore.remove(any())).thenAnswer((_) async {});

      await dataSource.prune(retainedKeys);

      verifyNever(() => mockKeyValueStore.remove(any()));
    });
  });
}
