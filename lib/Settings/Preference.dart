
import 'package:shared_preferences/shared_preferences.dart';

/// Preference
class Preference {
  static const URL = 'url';
  static const USERNAME = 'username';
  /// legacy key: the password now lives in [CredentialStore]; only read to
  /// move an old value over
  static const PASSWORD = 'password';
  static const USERID = 'userid';
  static const ORGID = 'orgid';
  static const TOUR = "tour";
  static const PROMINENT_DISCLOSURE_CONFIRMED = "prominent_disclosure_confirmed";
  static const DARK_MODE = "isDarkMode";
  /// UI language code (en/de/es), see LocaleController
  static const LANGUAGE = "language";
  /// tour started automatically by leaving the home area (resumed after an
  /// app restart on the same day)
  static const HOME_AREA_TOUR = "home_area_tour";
  /// keep the display on while the app is in front (tour settings)
  static const KEEP_SCREEN_ON = "keep_screen_on";
  /// end of the last successful sync (ISO 8601), see SyncController
  static const LAST_SYNC = "last_sync";

  SharedPreferences? prefs;

  /// load
  Future<void> load() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// getUrl
  String getUrl() {
    if (prefs != null) {
      if (prefs!.containsKey(Preference.URL)) {
        return prefs!.getString(Preference.URL) ?? '';
      }
    }

    return '';
  }

  /// getUsername
  String getUsername() {
    if (prefs != null) {
      if (prefs!.containsKey(Preference.USERNAME)) {
        return prefs!.getString(Preference.USERNAME) ?? '';
      }
    }

    return '';
  }

  /// getUserId
  int getUserId() {
    if (prefs != null) {
      if (prefs!.containsKey(Preference.USERID)) {
        return prefs!.getInt(Preference.USERID) ?? 0;
      }
    }

    return 0;
  }

  /// getOrgId
  int getOrgId() {
    if (prefs != null) {
      if (prefs!.containsKey(Preference.ORGID)) {
        return prefs!.getInt(Preference.ORGID) ?? 0;
      }
    }

    return 0;
  }

  /// getProminentDisclosureConfirmed
  bool getProminentDisclosureConfirmed() {
    if (prefs != null) {
      if (prefs!.containsKey(Preference.PROMINENT_DISCLOSURE_CONFIRMED)) {
        return prefs!.getBool(Preference.PROMINENT_DISCLOSURE_CONFIRMED) ?? false;
      }
    }

    return false;
  }
}