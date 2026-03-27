import 'package:flutter_test/flutter_test.dart';
import 'package:local_config/src/domain/entities/local_config_value.dart';

void main() {
  group('LocalConfigValue', () {
    test('should return default value when override is null', () {
      final value = LocalConfigValue(
        type: LocalConfigType.string,
        defaultValue: 'default',
      );

      expect(value.isDefault, isTrue);
      expect(value.hasOverride, isFalse);
      expect(value.asString, 'default');
    });

    test(
      'should return override value when it exists and differs from default',
      () {
        final value = LocalConfigValue(
          type: LocalConfigType.string,
          defaultValue: 'default',
          overrideValue: 'override',
        );

        expect(value.isDefault, isFalse);
        expect(value.hasOverride, isTrue);
        expect(value.asString, 'override');
      },
    );

    test('should treat override equal to default as default', () {
      final value = LocalConfigValue(
        type: LocalConfigType.string,
        defaultValue: 'same',
        overrideValue: 'same',
      );

      expect(value.isDefault, isTrue);
      expect(value.hasOverride, isFalse);
    });

    test('should parse value as int when possible', () {
      final value = LocalConfigValue(
        type: LocalConfigType.number,
        defaultValue: '10',
      );

      expect(value.asInt, 10);
    });

    test('should parse value as double when possible', () {
      final value = LocalConfigValue(
        type: LocalConfigType.number,
        defaultValue: '10.5',
      );

      expect(value.asDouble, 10.5);
    });

    test('should return null when parsing invalid int', () {
      final value = LocalConfigValue(
        type: LocalConfigType.string,
        defaultValue: 'abc',
      );

      expect(value.asInt, isNull);
    });

    test('should parse value as bool when possible', () {
      final value = LocalConfigValue(
        type: LocalConfigType.boolean,
        defaultValue: 'true',
      );

      expect(value.asBool, isTrue);
    });

    test('should return null when parsing invalid bool', () {
      final value = LocalConfigValue(
        type: LocalConfigType.string,
        defaultValue: 'not_bool',
      );

      expect(value.asBool, isNull);
    });

    test('should parse value as json when possible', () {
      final value = LocalConfigValue(
        type: LocalConfigType.json,
        defaultValue: '{"a":1}',
      );

      expect(value.asJson, {'a': 1});
    });

    test('should return null when parsing invalid json', () {
      final value = LocalConfigValue(
        type: LocalConfigType.string,
        defaultValue: 'not_json',
      );

      expect(value.asJson, isNull);
    });

    test('should create new instance with override using withOverride', () {
      final value = LocalConfigValue(
        type: LocalConfigType.string,
        defaultValue: 'default',
      );

      final updated = value.withOverride('override');

      expect(updated.asString, 'override');
      expect(updated.hasOverride, isTrue);
      expect(value.overrideValue, isNull); // original unchanged
    });

    test('should support equality comparison', () {
      final a = LocalConfigValue(
        type: LocalConfigType.string,
        defaultValue: 'a',
      );

      final b = LocalConfigValue(
        type: LocalConfigType.string,
        defaultValue: 'a',
      );

      expect(a, equals(b));
    });

    test('should include override in equality comparison', () {
      final a = LocalConfigValue(
        type: LocalConfigType.string,
        defaultValue: 'a',
        overrideValue: 'b',
      );

      final b = LocalConfigValue(
        type: LocalConfigType.string,
        defaultValue: 'a',
        overrideValue: 'c',
      );

      expect(a == b, isFalse);
    });

    test('should return string representation of current value', () {
      final value = LocalConfigValue(
        type: LocalConfigType.string,
        defaultValue: 'default',
        overrideValue: 'override',
      );

      expect(value.toString(), 'override');
    });

    test(
      'should throw assertion error when default type does not match inferred type',
      () {
        expect(
          () => LocalConfigValue(
            type: LocalConfigType.boolean,
            defaultValue: 'not_bool',
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'should throw assertion error when override type does not match inferred type',
      () {
        expect(
          () => LocalConfigValue(
            type: LocalConfigType.boolean,
            defaultValue: 'true',
            overrideValue: 'not_bool',
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );
  });

  group('LocalConfigType.infer', () {
    test('should infer number type from numeric string', () {
      expect(LocalConfigType.infer('10'), LocalConfigType.number);
      expect(LocalConfigType.infer('10.5'), LocalConfigType.number);
    });

    test('should infer boolean type from boolean string', () {
      expect(LocalConfigType.infer('true'), LocalConfigType.boolean);
      expect(LocalConfigType.infer('false'), LocalConfigType.boolean);
    });

    test('should infer json type from json string', () {
      expect(LocalConfigType.infer('{"a":1}'), LocalConfigType.json);
      expect(LocalConfigType.infer('[1,2,3]'), LocalConfigType.json);
    });

    test('should infer string type when no other type matches', () {
      expect(LocalConfigType.infer('hello'), LocalConfigType.string);
    });
  });

  group('LocalConfigType.isTextBased', () {
    test('should return true for string and json types', () {
      expect(LocalConfigType.string.isTextBased, isTrue);
      expect(LocalConfigType.json.isTextBased, isTrue);
    });

    test('should return false for non-text types', () {
      expect(LocalConfigType.boolean.isTextBased, isFalse);
      expect(LocalConfigType.number.isTextBased, isFalse);
    });
  });
}
