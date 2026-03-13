import 'package:flutter_test/flutter_test.dart';
import 'package:local_config/src/common/utils/case_validators.dart';

void main() {
  group('isSnakeCase', () {
    test('returns true for lowercase snake case', () {
      expect(isSnakeCase('abc_123'), isTrue);
    });

    test('returns false for empty string', () {
      expect(isSnakeCase(''), isFalse);
    });

    test('returns false for uppercase letters', () {
      expect(isSnakeCase('Abc'), isFalse);
    });

    test(
      'returns false for characters other than lowercase letters, digits, or underscore',
      () {
        expect(isSnakeCase('a-b'), isFalse);
        expect(isSnakeCase('abc def'), isFalse);
        expect(isSnakeCase('abc@def'), isFalse);
        expect(isSnakeCase('abc/def'), isFalse);
        expect(isSnakeCase('çãõ'), isFalse);
      },
    );
  });
}
