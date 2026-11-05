
import 'package:flutter/material.dart';
import 'package:mwpaapp/Ui/Fonts.dart';

// Accepted backend API versions. The mobile app refuses to talk to a server
// that returns a value outside these sets, because the wire shape may have
// drifted in a way that would corrupt the local data on sync. Add a new
// version string here when the server bumps but stays wire-compatible.
const Set<String> versionApiMobileLogin = {'1.0.1'};
const Set<String> versionApiMobileSync = {'1.0.2', '1.0.3'};

/// isDarkMode - true when the active theme of [context] is dark
bool isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

// primary
const kPrimaryColor = Color(0xff022b55);
const kPrimaryBackgroundColor = Color(0xffffffff);
const kPrimaryDarkBackgroundColor = Colors.black38;
const kPrimaryHeaderColor = Color(0xff0b4297);
const kPrimaryFontColor = Color(0xff333333);
const kPrimaryDarkFontColor = Color(0xffffffff);

// button
const kButtonBackgroundColor = Color(0xfff9901c);
const kButtonFontColor = Color(0xffffffff);

TextStyle subHeadingStyle(BuildContext context) {
  return latoStyle(
    textStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.grey[400]
    )
  );
}

TextStyle headingStyle(BuildContext context) {
  return latoStyle(
    textStyle: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: isDarkMode(context) ? kPrimaryDarkFontColor : kPrimaryFontColor
    )
  );
}

TextStyle titleStyle(BuildContext context) {
  return latoStyle(
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: isDarkMode(context) ? kPrimaryDarkFontColor : kPrimaryFontColor
    )
  );
}

TextStyle subTitleStyle(BuildContext context) {
  return latoStyle(
      textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDarkMode(context) ? kPrimaryDarkFontColor : kPrimaryFontColor,
      )
  );
}