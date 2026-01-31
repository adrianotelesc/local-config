import 'dart:convert';

Map<String, dynamic>? tryJsonDecode(String source) {
  try {
    return jsonDecode(source);
  } catch (_) {
    return null;
  }
}

String? tryJsonEncode(Object object) {
  try {
    return jsonEncode(object);
  } catch (_) {
    return null;
  }
}
