import 'package:flutter/material.dart';
import 'package:local_config/delegate/editor_delegate.dart';
import 'package:local_config/delegate/json_editor_delegate.dart';
import 'package:local_config/delegate/string_editor_delegate.dart';
import 'package:local_config/extension/string_parsing_extension.dart';
import 'package:local_config/model/config.dart';

extension ConfigDisplayExtension on Config {
  String get displayText {
    switch (type) {
      case ConfigType.string:
        return value.isNotEmpty ? value : '(empty string)';
      default:
        return value;
    }
  }
}

extension ConfigTypeDisplayExtension on ConfigType {
  List<String> get presets {
    return this == ConfigType.boolean ? ['false', 'true'] : [];
  }

  String get displayName {
    return switch (this) {
      ConfigType.boolean => 'Boolean',
      ConfigType.number => 'Number',
      ConfigType.string => 'String',
      ConfigType.json => 'JSON',
    };
  }

  IconData get icon {
    return switch (this) {
      ConfigType.boolean => Icons.toggle_on,
      ConfigType.number => Icons.onetwothree,
      ConfigType.string => Icons.abc,
      ConfigType.json => Icons.data_object
    };
  }

  String? validator(String? value) {
    if (this == ConfigType.boolean && value?.asBool == null) {
      return 'Invalid bolean';
    }
    if (this == ConfigType.number && value?.asDouble == null) {
      return 'Invalid number';
    }
    if (this == ConfigType.json && value?.asJson == null) {
      return 'Invalid JSON';
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
