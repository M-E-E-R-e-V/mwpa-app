
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// primary
const kPrimaryColor = Color(0xff022b55);
const kPrimaryBackgroundColor = Color(0xffffffff);
const kPrimaryHeaderColor = Color(0xff0b4297);
const kPrimaryFontColor = Color(0xff333333);

// button
const kButtonBackgroundColor = Color(0xfff9901c);
const kButtonFontColor = Color(0xffffffff);

TextStyle get subHeadingStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.grey[400]
    )
  );
}

TextStyle get headingStyle {
  return GoogleFonts.lato(
    textStyle: const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: kPrimaryFontColor
    )
  );
}

TextStyle get titleStyle {
  return GoogleFonts.lato(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: kPrimaryFontColor
    )
  );
}

TextStyle get subTitleStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: kPrimaryFontColor,
      )
  );
}