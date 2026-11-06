import 'package:flutter/material.dart';
import 'package:mwpaapp/Ui/Fonts.dart';
import 'package:mwpaapp/Constants.dart';

class Themes {
  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    brightness: Brightness.light,
    primary: kPrimaryColor,
    secondary: kPrimaryHeaderColor,
    tertiary: kButtonBackgroundColor,
  );

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    brightness: Brightness.dark,
    primary: kPrimaryHeaderColor,
    secondary: kButtonBackgroundColor,
  );

  /// buttons/links on the dark background: the brand blues are too dark
  /// there (same value as inputAccentColor)
  static const Color darkAccent = Color(0xff9ec3ff);

  static final light = _build(_lightScheme);
  static final dark = _build(_darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scheme.brightness == Brightness.dark
          ? kPrimaryDarkBackgroundColor
          : kPrimaryBackgroundColor,
      fontFamily: kFontFamily,
      textTheme: ThemeData(brightness: scheme.brightness)
          .textTheme
          .apply(fontFamily: kFontFamily),
    );

    final inputTheme = InputDecorationTheme(
      filled: true,
      fillColor: scheme.brightness == Brightness.dark
          ? scheme.surfaceContainerHighest
          : Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: kPrimaryHeaderColor,
        foregroundColor: kButtonFontColor,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: latoStyle(
          textStyle: const TextStyle(
            color: kButtonFontColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: kButtonFontColor),
      ),
      inputDecorationTheme: inputTheme,
      // DropdownMenu ignores inputDecorationTheme and is unfilled by
      // default - without this the select boxes look disabled
      dropdownMenuTheme: DropdownMenuThemeData(inputDecorationTheme: inputTheme),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: latoStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          backgroundColor: kPrimaryHeaderColor,
          foregroundColor: kButtonFontColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: latoStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          side: BorderSide(color: dark ? darkAccent : kPrimaryColor, width: 1.4),
          foregroundColor: dark ? darkAccent : kPrimaryColor,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dark ? darkAccent : scheme.primary,
          textStyle: latoStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}