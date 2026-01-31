import 'package:flutter_test/flutter_test.dart';
import 'package:local_config/src/common/extension/string_extension.dart';

void main() {
  group('StringExtension.containsInsensitive', () {
    const string = 'Hello World';

    test('returns true when substring exists ignoring lowercase', () {
      const substring = 'hello';

      final result = string.containsInsensitive(substring);

      expect(result, isTrue);
    });

    test('returns true when substring exists ignoring uppercase', () {
      const substring = 'WORLD';

      final result = string.containsInsensitive(substring);

      expect(result, isTrue);
    });

    test('returns false when substring does not exist', () {
      const substring = 'dart';

      final result = string.containsInsensitive(substring);

      expect(result, isFalse);
    });

    test('matches empty substring', () {
      const substring = '';

      final result = string.containsInsensitive(substring);

      expect(result, isTrue);
    });
  });
}
