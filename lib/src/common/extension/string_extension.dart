import 'dart:convert';

const _leadingZeroIntRegExp = r'^0\d+$';
const _leadingZeroDoubleRegExp = r'^0\d+(\.\d+)?$';

extension StringExtension on String {
  Map<String, dynamic>? toMapOrNull() {
    try {
      return jsonDecode(this);
    } catch (_) {
      return null;
    }
  }

  bool? toBoolOrNull() => bool.tryParse(this);

  int? toStrictIntOrNull() {
    if (RegExp(_leadingZeroIntRegExp).hasMatch(this)) {
      return null;
    }

    return int.tryParse(this);
  }

  double? toStrictDoubleOrNull() {
    if (RegExp(_leadingZeroDoubleRegExp).hasMatch(this)) {
      return null;
    }

    return double.tryParse(this);
  }

  bool containsInsensitive(String other) =>
      toLowerCase().contains(other.toLowerCase());
}
