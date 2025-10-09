import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_config/data/util/key_namespace.dart';
import 'package:local_config/data/data_source/local_config_data_source.dart';
import 'package:local_config/core/storage/key_value_store.dart';

class MockKeyValueStore extends Mock implements KeyValueStore {}

class MockKeyNamespace extends Mock implements KeyNamespace {}

const namespace = 'test';

void main() {
  late MockKeyNamespace mockKeyNamespace;

  late MockKeyValueStore mockKeyValueStore;

  late LocalConfigDataSource dataSource;

  setUp(() {
    mockKeyNamespace = MockKeyNamespace();

    mockKeyValueStore = MockKeyValueStore();

    dataSource = LocalConfigDataSource(
      keyNamespace: mockKeyNamespace,
      keyValueStore: mockKeyValueStore,
    );
  });

  group('LocalConfigDataSource.all', () {
    test('returns only namespaced keys with prefix removed', () async {
      const all = {
        'local_config:foo': 'bar',
        'other:key': 'value',
      };

      when(() => mockKeyValueStore.all).thenAnswer((_) async => all);
      when(
        () => mockKeyNamespace.matches('local_config:foo'),
      ).thenAnswer((_) => true);
      when(
        () => mockKeyNamespace.matches('other:key'),
      ).thenAnswer((_) => false);
      when(
        () => mockKeyNamespace.strip('local_config:foo'),
      ).thenAnswer((_) => 'foo');

      final result = await dataSource.all;

      expect(result.length, 1);
      expect(result['foo'], 'bar');
      expect(result.containsKey('other:key'), isFalse);
    });

    test('returns empty map if no namespaced keys', () async {
      const all = {'other:key': 'value'};

      when(() => mockKeyValueStore.all).thenAnswer((_) async => all);
      when(
        () => mockKeyNamespace.matches('other:key'),
      ).thenAnswer((_) => false);

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
      when(
        () => mockKeyNamespace.apply(key),
      ).thenReturn('local_config:foo');

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
      when(
        () => mockKeyNamespace.apply(key),
      ).thenReturn('local_config:foo');

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
      when(
        () => mockKeyNamespace.apply(key),
      ).thenReturn('local_config:foo');

      await dataSource.remove(key);

      verify(() => mockKeyValueStore.remove('local_config:foo')).called(1);
    });
  });

  group('LocalConfigDataSource.clear', () {
    test('removes all namespaced keys', () async {
      const all = {
        'local_config:foo': 'bar',
        'other:key': 'value',
      };

      when(() => mockKeyValueStore.all).thenAnswer((_) async => all);
      when(
        () => mockKeyNamespace.matches('local_config:foo'),
      ).thenAnswer((_) => true);
      when(
        () => mockKeyNamespace.matches('other:key'),
      ).thenAnswer((_) => false);
      when(
        () => mockKeyNamespace.strip('local_config:foo'),
      ).thenAnswer((_) => 'foo');
      when(
        () => mockKeyNamespace.apply('foo'),
      ).thenAnswer((_) => 'local_config:foo');
      when(
        () => mockKeyValueStore.remove('local_config:foo'),
      ).thenAnswer((_) async {});

      await dataSource.clear();

      verify(() => mockKeyValueStore.remove('local_config:foo')).called(1);
      verifyNever(() => mockKeyValueStore.remove('other:key'));
    });

    test('does nothing if no namespaced keys exist', () async {
      when(() => mockKeyValueStore.all).thenAnswer((_) async => {});
      when(() => mockKeyNamespace.matches(any())).thenReturn(false);

      await dataSource.clear();

      verifyNever(() => mockKeyValueStore.remove(any()));
    });
  });

  group('LocalConfigDataSource.prune', () {
    test('removes keys not in retainedKeys', () async {
      const all = {
        'local_config:foo': 'bar',
        'local_config:baz': 'qux',
      };
      const retainedKeys = {'baz'};

      when(() => mockKeyValueStore.all).thenAnswer((_) async => all);
      when(
        () => mockKeyNamespace.matches('local_config:foo'),
      ).thenAnswer((_) => true);
      when(
        () => mockKeyNamespace.matches('local_config:baz'),
      ).thenAnswer((_) => true);
      when(
        () => mockKeyNamespace.strip('local_config:foo'),
      ).thenAnswer((_) => 'foo');
      when(
        () => mockKeyNamespace.strip('local_config:baz'),
      ).thenAnswer((_) => 'baz');
      when(
        () => mockKeyNamespace.apply('foo'),
      ).thenAnswer((_) => 'local_config:foo');
      when(
        () => mockKeyValueStore.remove('local_config:foo'),
      ).thenAnswer((_) async {});

      await dataSource.prune(retainedKeys);

      verify(() => mockKeyValueStore.remove('local_config:foo')).called(1);
      verifyNever(() => mockKeyValueStore.remove('local_config:baz'));
    });

    test('does not remove anything if all keys are retained', () async {
      const all = {
        'local_config:foo': 'bar',
        'local_config:baz': 'qux',
      };
      const retainedKeys = {'foo', 'baz'};

      when(() => mockKeyValueStore.all).thenAnswer((_) async => all);
      when(
        () => mockKeyNamespace.matches('local_config:foo'),
      ).thenAnswer((_) => true);
      when(
        () => mockKeyNamespace.matches('local_config:baz'),
      ).thenAnswer((_) => true);
      when(
        () => mockKeyNamespace.strip('local_config:foo'),
      ).thenAnswer((_) => 'foo');
      when(
        () => mockKeyNamespace.strip('local_config:baz'),
      ).thenAnswer((_) => 'baz');
      when(() => mockKeyValueStore.remove(any())).thenAnswer((_) async {});

      await dataSource.prune(retainedKeys);

      verifyNever(() => mockKeyValueStore.remove(any()));
    });
  });
}
