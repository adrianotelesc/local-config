import 'package:flutter_test/flutter_test.dart';
import 'package:local_config/src/common/utils/type_converters.dart';

void main() {
  group('tryParseBool', () {
    test('returns true for bool true', () {
      expect(tryParseBool(true), isTrue);
    });

    test('returns false for bool false', () {
      expect(tryParseBool(false), isFalse);
    });

    test('returns true for num 1', () {
      expect(tryParseBool(1), isTrue);
    });

    test('returns false for num 0', () {
      expect(tryParseBool(0), isFalse);
    });

    test('returns null for other num', () {
      expect(tryParseBool(2), isNull);
    });

    test('returns true for string "true"', () {
      expect(tryParseBool('true'), isTrue);
    });

    test('returns false for string "false"', () {
      expect(tryParseBool('false'), isFalse);
    });

    test('returns true for string "1"', () {
      expect(tryParseBool('1'), isTrue);
    });

    test('returns false for string "0"', () {
      expect(tryParseBool('0'), isFalse);
    });

    test('returns null for invalid string', () {
      expect(tryParseBool('yes'), isNull);
    });

    test('returns null for other types', () {
      expect(tryParseBool({}), isNull);
    });
  });

  group('stringify', () {
    test('returns string as is', () {
      expect(stringify('hello'), 'hello');
    });

    test('returns JSON for Map', () {
      expect(stringify({'key': 'value'}), '{"key":"value"}');
    });

    test('returns JSON for List', () {
      expect(stringify([1, 2, 3]), '[1,2,3]');
    });

    test('returns toString for other objects', () {
      expect(stringify(42), '42');
    });

    test('falls back to toString for unencodable Map', () {
      final unencodable = {'key': Object()};
      expect(stringify(unencodable), unencodable.toString());
    });
  });

  group('tryJsonDecode', () {
    test('returns map for valid json object', () {
      const json = '{"a":1,"b":"x"}';

      final result = tryJsonDecode(json) as Map<String, dynamic>;

      expect(result['a'], 1);
      expect(result['b'], 'x');
    });

    test('returns null for invalid json', () {
      const json = '{"a":1,';

      final result = tryJsonDecode(json);

      expect(result, isNull);
    });

    test('returns null for non-json string', () {
      const json = 'not json';

      final result = tryJsonDecode(json);

      expect(result, isNull);
    });

    test('returns list when json is a array', () {
      const json = '[1,2,3]';

      final result = tryJsonDecode(json) as List;

      expect(result[0], 1);
      expect(result[1], 2);
      expect(result[2], 3);
    });

    test('returns value when json is a primitive', () {
      const json = '123';

      final result = tryJsonDecode(json);

      expect(result, 123);
    });

    test('returns null for empty string', () {
      final result = tryJsonDecode('');

      expect(result, isNull);
    });
  });

  group('tryJsonEncode', () {
    test('encodes map successfully', () {
      final obj = {'a': 1, 'b': 'x'};

      final result = tryJsonEncode(obj);

      expect(result, isNotNull);
      expect(result, contains('"a":1'));
      expect(result, contains('"b":"x"'));
    });

    test('encodes list successfully', () {
      final object = [1, 2, 3];

      final result = tryJsonEncode(object);

      expect(result, '[1,2,3]');
    });

    test('encodes primitive successfully', () {
      final result = tryJsonEncode(123);

      expect(result, '123');
    });

    test('returns null for non-encodable object', () {
      final object = Object();

      final result = tryJsonEncode(object);

      expect(result, isNull);
    });

    test('returns null for object with non-encodable value', () {
      final object = {'a': Object()};

      final result = tryJsonEncode(object);

      expect(result, isNull);
    });
  });
}
