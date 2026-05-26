import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static final light = _build(_lightScheme);
  static final dark = _build(_darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scheme.brightness == Brightness.dark
          ? kPrimaryDarkBackgroundColor
          : kPrimaryBackgroundColor,
      textTheme: GoogleFonts.latoTextTheme(
        ThemeData(brightness: scheme.brightness).textTheme,
      ),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: kPrimaryHeaderColor,
        foregroundColor: kButtonFontColor,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: kButtonFontColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: kButtonFontColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
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
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.lato(
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
          textStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          side: const BorderSide(color: kPrimaryColor, width: 1.4),
          foregroundColor: kPrimaryColor,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.w600),
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