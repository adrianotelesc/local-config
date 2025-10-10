import 'package:flutter_test/flutter_test.dart';
import 'package:local_config/core/storage/key_value_store.dart';
import 'package:local_config/data/data_source/default_config_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockKeyValueStore extends Mock implements KeyValueStore {}

void main() {
  late MockKeyValueStore mockStore;
  late DefaultConfigDataSource dataSource;

  setUp(() {
    mockStore = MockKeyValueStore();
    dataSource = DefaultConfigDataSource(keyValueStore: mockStore);
  });

  group('DefaultConfigDataSource', () {
    test('get() delegates to KeyValueStore.getString()', () async {
      when(() => mockStore.getString('theme')).thenAnswer((_) async => 'dark');

      final result = await dataSource.get('theme');

      expect(result, 'dark');
      verify(() => mockStore.getString('theme')).called(1);
    });

    test('set() delegates to KeyValueStore.setString()', () async {
      when(
        () => mockStore.setString('theme', 'light'),
      ).thenAnswer((_) async {});

      await dataSource.set('theme', 'light');

      verify(() => mockStore.setString('theme', 'light')).called(1);
    });

    test('remove() delegates to KeyValueStore.remove()', () async {
      when(() => mockStore.remove('theme')).thenAnswer((_) async {});

      await dataSource.remove('theme');

      verify(() => mockStore.remove('theme')).called(1);
    });

    test('all returns stringified map from KeyValueStore', () async {
      when(() => mockStore.all).thenAnswer(
        (_) async => {'a': 1, 'b': true, 'c': 'str'},
      );

      final result = await dataSource.all;

      expect(result, {'a': '1', 'b': 'true', 'c': 'str'});
      verify(() => mockStore.all).called(1);
    });

    test('clear removes all existing keys', () async {
      when(
        () => mockStore.all,
      ).thenAnswer((_) async => {'a': '1', 'b': '2', 'c': '3'});
      when(() => mockStore.remove(any())).thenAnswer((_) async {});

      await dataSource.clear();

      verify(() => mockStore.remove('a')).called(1);
      verify(() => mockStore.remove('b')).called(1);
      verify(() => mockStore.remove('c')).called(1);
    });

    test('prune removes only non-retained keys', () async {
      when(
        () => mockStore.all,
      ).thenAnswer((_) async => {'a': '1', 'b': '2', 'c': '3'});
      when(() => mockStore.remove(any())).thenAnswer((_) async {});

      await dataSource.prune({'a', 'c'});

      verifyNever(() => mockStore.remove('a'));
      verify(() => mockStore.remove('b')).called(1);
      verifyNever(() => mockStore.remove('c'));
    });

    test('clear does nothing when store is empty', () async {
      when(() => mockStore.all).thenAnswer((_) async => {});
      // No removes expected
      await dataSource.clear();

      verifyNever(() => mockStore.remove(any()));
    });
  });
}
