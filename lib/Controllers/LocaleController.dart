import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppLanguage - the languages of the app UI, in the order of the selection
enum AppLanguage {
  en('English', '🇬🇧'),
  de('Deutsch', '🇩🇪'),
  es('Español', '🇪🇸');

  /// name in its own language
  final String nativeName;
  final String flag;

  const AppLanguage(this.nativeName, this.flag);

  Locale get locale => Locale(name);

  static AppLanguage fromCode(String? code) =>
      AppLanguage.values.firstWhere((l) => l.name == code, orElse: () => AppLanguage.en);
}

/// LocaleController - selected UI language (default English), persisted
class LocaleController extends ChangeNotifier {
  AppLanguage _language = AppLanguage.en;

  AppLanguage get language => _language;

  Locale get locale => _language.locale;

  /// load
  Future<void> load() async {
    // DateFormat throws for a default locale whose date symbols are not
    // loaded yet; the material delegate loads them only with the first build
    await initializeDateFormatting();

    final prefs = await SharedPreferences.getInstance();
    _language = AppLanguage.fromCode(prefs.getString(Preference.LANGUAGE));
    Intl.defaultLocale = _language.name;
    notifyListeners();
  }

  /// setLanguage
  Future<void> setLanguage(AppLanguage language) async {
    if (language == _language) {
      return;
    }

    _language = language;
    // date formats (DateFormat) follow the UI language
    Intl.defaultLocale = language.name;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Preference.LANGUAGE, language.name);
  }
}
