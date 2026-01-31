import 'package:flutter/material.dart';
import 'package:local_config/src/ui/theme/local_config_colors.dart';
import 'package:local_config/src/ui/theme/extended_color_scheme.dart';
import 'package:local_config/src/ui/theme/local_config_radius.dart';

abstract final class LocalConfigTheme {
  static ColorScheme get _colorScheme => ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: LocalConfigColors.seedColor,
  );

  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(LocalConfigRadii.medium),
      borderSide: BorderSide(color: _colorScheme.primary, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(LocalConfigRadii.medium),
      borderSide: BorderSide(color: _colorScheme.outline),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(LocalConfigRadii.medium),
      borderSide: BorderSide(color: _colorScheme.outline),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(LocalConfigRadii.medium),
      borderSide: BorderSide(color: _colorScheme.onSurface.withAlpha(23)),
    ),
  );

  static ThemeData get data => ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _colorScheme.surface,
      surfaceTintColor: _colorScheme.surface,
    ),
    inputDecorationTheme: _inputDecorationTheme,
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: TextStyle(color: _colorScheme.onSurface),
      inputDecorationTheme: _inputDecorationTheme,
      menuStyle: MenuStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LocalConfigRadii.medium),
          ),
        ),

        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(),
    ),
    searchBarTheme: SearchBarThemeData(
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _colorScheme.primary,
      selectionColor: _colorScheme.primary.withAlpha(102),
      selectionHandleColor: _colorScheme.primary,
    ),
    extensions: [
      ExtendedColorScheme(
        warning: LocalConfigColors.warning,
        warningContainer: LocalConfigColors.warningContainer,
        onWarning: LocalConfigColors.onWarning,
        onWarningContainer: LocalConfigColors.onWarningContainer,
        success: LocalConfigColors.success,
        onSuccess: LocalConfigColors.onSuccess,
        successContainer: LocalConfigColors.successContainer,
        onSuccessContainer: LocalConfigColors.onSuccessContainer,
      ),
    ],
  );
}
