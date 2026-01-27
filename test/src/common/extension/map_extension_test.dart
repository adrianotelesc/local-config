import 'dart:convert';

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
    test('should convert primitive types to string', () {
      final map = {'int': 1, 'double': 1.5, 'bool': true, 'string': 'hello'};

      final result = map.stringify();

      expect(result, {
        'int': '1',
        'double': '1.5',
        'bool': 'true',
        'string': 'hello',
      });
    });

    test('should convert null values to empty string', () {
      final map = {'key': null};

      final result = map.stringify();

      expect(result, {'key': ''});
    });

    test('should remove null keys', () {
      final map = {null: 'value', 'key': 'value'};

      final result = map.stringify();

      expect(result, {'key': 'value'});
    });

    test('should remove empty string keys', () {
      final map = {'': 'value', 'key': 'value'};

      final result = map.stringify();

      expect(result, {'key': 'value'});
    });

    test('should serialize Map values as JSON', () {
      final map = {
        'config': {'a': 1, 'b': 2},
      };

      final result = map.stringify();

      expect(result['config'], jsonEncode({'a': 1, 'b': 2}));
    });

    test('should serialize List values as JSON', () {
      final map = {
        'list': [1, 2, 3],
      };

      final result = map.stringify();

      expect(result['list'], jsonEncode([1, 2, 3]));
    });

    test('should handle nested structures', () {
      final map = {
        'nested': {
          'a': [1, 2],
          'b': {'c': true},
        },
      };

      final result = map.stringify();

      expect(
        result['nested'],
        jsonEncode({
          'a': [1, 2],
          'b': {'c': true},
        }),
      );
    });

    test('should fallback to toString for custom objects', () {
      final obj = Object();
      final map = {'obj': obj};

      final result = map.stringify();

      expect(result['obj'], obj.toString());
    });

    test('should handle mixed types and invalid keys', () {
      final map = {
        null: null,
        '': 1,
        123: {'x': 10},
        'valid': [1, 2],
      };

      final result = map.stringify();

      expect(result, {
        '123': jsonEncode({'x': 10}),
        'valid': jsonEncode([1, 2]),
      });
    });

    test('should return empty map when all keys are invalid', () {
      final map = {null: 1, '': 2};

      final result = map.stringify();

      expect(result, isEmpty);
    });
  });
}
