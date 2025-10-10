import 'package:flutter_test/flutter_test.dart';
import 'package:local_config/core/storage/key_value_store.dart';
import 'package:local_config/infra/storage/namespaced_key_value_store.dart';
import 'package:local_config/infra/util/key_namespace.dart';
import 'package:mocktail/mocktail.dart';

class MockKeyNamespace extends Mock implements KeyNamespace {}

class MockKeyValueStore extends Mock implements KeyValueStore {}

void main() {
  late MockKeyValueStore mockInnerStore;
  late MockKeyNamespace mockKeyNamespace;
  late NamespacedKeyValueStore store;

  setUp(() {
    mockInnerStore = MockKeyValueStore();
    mockKeyNamespace = MockKeyNamespace();

    store = NamespacedKeyValueStore(
      keyNamespace: mockKeyNamespace,
      innerStore: mockInnerStore,
    );
  });

  group('NamespacedKeyValueStore.all', () {
    test('returns only namespaced keys with prefix removed', () async {
      const all = {
        'ns:foo': 'bar',
        'other:key': 'value',
      };

      when(() => mockInnerStore.all).thenAnswer((_) async => all);
      when(() => mockKeyNamespace.matches('ns:foo')).thenReturn(true);
      when(() => mockKeyNamespace.matches('other:key')).thenReturn(false);
      when(() => mockKeyNamespace.strip('ns:foo')).thenReturn('foo');

      final result = await store.all;

      expect(result.length, 1);
      expect(result['foo'], 'bar');
      expect(result.containsKey('other:key'), isFalse);
    });

    test('returns empty map when no namespaced keys', () async {
      const all = {'other:key': 'value'};

      when(() => mockInnerStore.all).thenAnswer((_) async => all);
      when(() => mockKeyNamespace.matches('other:key')).thenReturn(false);

      final result = await store.all;

      expect(result, isEmpty);
    });
  });

  group('NamespacedKeyValueStore.getString', () {
    test('applies namespace and delegates to inner store', () async {
      const key = 'foo';
      const namespacedKey = 'ns:foo';
      const value = 'bar';

      when(() => mockKeyNamespace.apply(key)).thenReturn(namespacedKey);
      when(
        () => mockInnerStore.getString(namespacedKey),
      ).thenAnswer((_) async => value);

      final result = await store.getString(key);

      expect(result, value);
      verify(() => mockKeyNamespace.apply(key)).called(1);
      verify(() => mockInnerStore.getString(namespacedKey)).called(1);
    });
  });

  group('NamespacedKeyValueStore.setString', () {
    test('applies namespace and delegates to inner store', () async {
      const key = 'foo';
      const value = 'bar';
      const namespacedKey = 'ns:foo';

      when(() => mockKeyNamespace.apply(key)).thenReturn(namespacedKey);
      when(
        () => mockInnerStore.setString(namespacedKey, value),
      ).thenAnswer((_) async {});

      await store.setString(key, value);

      verify(() => mockKeyNamespace.apply(key)).called(1);
      verify(() => mockInnerStore.setString(namespacedKey, value)).called(1);
    });
  });

  group('NamespacedKeyValueStore.remove', () {
    test('applies namespace and delegates to inner store', () async {
      const key = 'foo';
      const namespacedKey = 'ns:foo';

      when(() => mockKeyNamespace.apply(key)).thenReturn(namespacedKey);
      when(() => mockInnerStore.remove(namespacedKey)).thenAnswer((_) async {});

      await store.remove(key);

      verify(() => mockKeyNamespace.apply(key)).called(1);
      verify(() => mockInnerStore.remove(namespacedKey)).called(1);
    });
  });
}
