import 'package:local_config/src/common/util/json_safe_convert.dart';

extension ObjectExtension on Object {
  String stringify() {
    if (this is String) return this as String;
    if (this is num || this is bool) return toString();
    if (this is Map || this is List) return tryJsonEncode(this) ?? toString();
    return toString();
  }
}
