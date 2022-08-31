import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

class Themes {
  static final light = ThemeData(
    primaryColor: kPrimaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white
  );

  static final dark = ThemeData(
      primaryColor: kPrimaryColor,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black38
  );
}