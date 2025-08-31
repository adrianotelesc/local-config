// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'local_config_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LocalConfigLocalizationsEn extends LocalConfigLocalizations {
  LocalConfigLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get localConfig => 'Local Config';

  @override
  String get search => 'Search';

  @override
  String get configsChangedLocally => 'Configs changed locally';

  @override
  String get changedLocally => 'Locally changed';

  @override
  String get revertAll => 'Revert all';

  @override
  String get revert => 'Revert';

  @override
  String get editParameter => 'Edit parameter';

  @override
  String get save => 'Save';

  @override
  String get parameterName => 'Parameter name (key)';

  @override
  String get dataType => 'Data type';

  @override
  String get value => 'Value';

  @override
  String get close => 'Close';

  @override
  String get fullScreenEditor => 'Full screen editor';

  @override
  String get noResults => 'Uuuh... Nothing here... Just emptiness...';

  @override
  String get whatAreTheConfigs => 'WHERE ARE THE CONFIGS!?';

  @override
  String get reasosForIssues =>
      'Hmm... this might be happening because:\n• Local Config SDK hasn’t been initialized yet.\n• Configs are still populating.';

  @override
  String get wait =>
      'If you\\\'ve been waiting a while, maybe your configs are... empty.';

  @override
  String get emptyString => '(empty string)';

  @override
  String get boolean => 'Boolean';

  @override
  String get number => 'Number';

  @override
  String get invalidBoolean => 'Invalid Boolean';

  @override
  String get invalidNumber => 'Invalid Number';

  @override
  String get invalidJson => 'Invalid JSON';

  @override
  String get help =>
      'This is the key you\'ll pass to the Local Config SDK,\nfor example:\n';

  @override
  String get validJson => 'Valid JSON';

  @override
  String get format => 'Format';

  @override
  String editorOf(Object type) {
    return '$type Editor';
  }
}
