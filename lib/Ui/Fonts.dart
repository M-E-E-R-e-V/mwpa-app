import 'package:flutter/material.dart';

/// Bundled app font (assets/fonts, SIL OFL 1.1). Shipped with the app instead
/// of google_fonts so text renders correctly offline on first start.
const String kFontFamily = 'Lato';

/// latoStyle - drop-in for the former GoogleFonts.lato(): explicit
/// [fontWeight]/[fontSize] override the values of [textStyle].
TextStyle latoStyle({TextStyle? textStyle, FontWeight? fontWeight, double? fontSize}) {
  return (textStyle ?? const TextStyle()).copyWith(
    fontFamily: kFontFamily,
    fontWeight: fontWeight,
    fontSize: fontSize,
  );
}
