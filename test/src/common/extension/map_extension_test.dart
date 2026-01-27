import 'package:flutter_test/flutter_test.dart';
import 'package:local_config/src/common/extension/map_extension.dart';

void main() {
  group('MapExtension.whereKey', () {
    final map = {'a': 1, 'b': 2, 'c': 3};

    test('returns filtered Map by key', () {
      final result = map.where((key, value) => key != 'b');

      expect(result.length, 2);
      expect(result.containsKey('a'), isTrue);
      expect(result.containsKey('c'), isTrue);
      expect(result.containsKey('b'), isFalse);
    });

    test('returns empty map when no keys pass test', () {
      final result = map.where((key, value) => key == 'z');

      expect(result, isEmpty);
    });

    test('returns full map when all keys pass test', () {
      final result = map.where((key, value) => true);

      expect(result, map);
    });
  });

  group('MapExtension.toRecordList', () {
    test('returns list of (key, value) tuples', () {
      const map = {'a': 1, 'b': 2, 'c': 3};

      final result = map.toRecordList();

      expect(result.length, 3);
      expect(result, contains(('a', 1)));
      expect(result, contains(('b', 2)));
      expect(result, contains(('c', 3)));
    });

    test('returns empty list for empty map', () {
      const map = {};

      final result = map.toRecordList();

      expect(result, isEmpty);
    });
  });

  group('MapExtension.anyValue', () {
    const map = {'a': 1, 'b': 2, 'c': 3};

    test('returns true when map has any value passes test', () {
      final result = map.anyValue((value) => value > 2);

      expect(result, isTrue);
    });

    test('returns false when map has none value passes test', () {
      final result = map.anyValue((value) => value > 5);

      expect(result, isFalse);
    });

    test('returns false when map is empty', () {
      const map = {};

      final result = map.anyValue((value) => true);

      expect(result, isFalse);
    });
  });

  group('MapExtension.stringify', () {
    test('should convert keys and values to String', () {
      final map = {1: 10, 'a': true};

      final result = map.stringify();

      expect(result, {'1': '10', 'a': 'true'});
    });

    test('should remove entries with null keys', () {
      final map = {null: 'value', 'key': 'value'};

      final result = map.stringify();

      expect(result, {'key': 'value'});
    });

    test('should convert null values to empty string', () {
      final map = {'key': null};

      final result = map.stringify();

      expect(result, {'key': ''});
    });

    test('should remove entries with empty string keys', () {
      final map = {'': 'value', 'key': 'value'};

      final result = map.stringify();

      expect(result, {'key': 'value'});
    });

    test('should handle mixed types and nulls', () {
      final map = {null: null, '': 1, 123: null, 'valid': 42};

      final result = map.stringify();

      expect(result, {'123': '', 'valid': '42'});
    });

    test('should return empty map when all keys are invalid', () {
      final map = {null: 1, '': 2};

      final result = map.stringify();

      expect(result, isEmpty);
    });
  });
}
