import 'package:flutter/material.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeController - holds the light/dark choice and persists it
class ThemeController extends ChangeNotifier {

  bool _isDarkMode = false;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// load
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(Preference.DARK_MODE) ?? false;
    notifyListeners();
  }

  /// switchTheme
  Future<void> switchTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Preference.DARK_MODE, _isDarkMode);
  }
}
