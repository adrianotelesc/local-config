import 'package:flutter_test/flutter_test.dart';
import 'package:local_config/src/common/util/json_safe_convert.dart';

void main() {
  group('StringExtension.toMapOrNull', () {
    test('returns Map when string is valid JSON', () {
      const string = '{"a":1,"b":2}';

      final result = tryJsonDecode(string);

      expect(result, isA<Map<String, dynamic>>());
      expect(result?['a'], 1);
      expect(result?['b'], 2);
    });

    test('returns null when string is not valid JSON', () {
      const string = 'not a json';

      final result = tryJsonDecode(string);

      expect(result, isNull);
    });

    test('returns Map when string is empty JSON', () {
      const string = '{}';

      final result = tryJsonDecode(string);

      expect(result, isA<Map<String, dynamic>>());
      expect(result, isEmpty);
    });
  });
}
