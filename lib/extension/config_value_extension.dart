import 'package:flutter/material.dart';
import 'package:local_config/delegate/editor_delegate.dart';
import 'package:local_config/delegate/json_editor_delegate.dart';
import 'package:local_config/delegate/string_editor_delegate.dart';
import 'package:local_config/extension/string_parsing.dart';
import 'package:local_config/model/config.dart';

extension ConfigTypeExtension on ConfigType {
  List<String> get presetValues {
    switch (this) {
      case ConfigType.boolean:
        return ['false', 'true'];
      default:
        return [];
    }
  }

  String get displayName {
    switch (this) {
      case ConfigType.boolean:
        return 'bool';
      case ConfigType.integer:
        return 'int';
      case ConfigType.decimal:
        return 'double';
      case ConfigType.string:
        return 'String';
      case ConfigType.json:
        return 'JSON';
    }
  }

  IconData get icon {
    switch (this) {
      case ConfigType.boolean:
        return Icons.toggle_on;
      case ConfigType.integer:
      case ConfigType.decimal:
        return Icons.onetwothree;
      case ConfigType.string:
        return Icons.abc;
      case ConfigType.json:
        return Icons.data_object;
    }
  }

  String? validator(String? value) {
    switch (this) {
      case ConfigType.boolean:
        if (value?.asBool == null) {
          return 'Invalid bolean';
        }
        break;
      case ConfigType.integer:
        if (value?.asInt == null) {
          return 'Invalid int';
        }
        break;
      case ConfigType.decimal:
        if (value?.asDouble == null) {
          return 'Invalid double';
        }
        break;
      case ConfigType.json:
        if (value?.asJson == null) {
          return 'Invalid JSON';
        }
        break;
      case ConfigType.string:
        break;
    }
    return null;
  }

  EditorDelegate get editorDelegate {
    switch (this) {
      case ConfigType.json:
        return JsonEditorDelegate();
      default:
        return StringDelegate();
    }
  }
}

extension ConfigValueExtension on Config {
  String get displayText {
    switch (type) {
      case ConfigType.string:
        return value.isNotEmpty ? value : '(empty string)';
      default:
        return value;
    }
  }
}
