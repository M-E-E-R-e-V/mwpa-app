import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mwpaapp/Util/AppLog.dart';

/// CredentialStore - keeps the login password in the platform's secure
/// storage (Android Keystore / iOS Keychain) instead of plain
/// shared_preferences. URL and username stay in shared_preferences.
/// Quick Connect devices keep a device token instead of the password (issued
/// by the server, replaces the password for the sync login).
class CredentialStore {
  static const String _passwordKey = 'mwpa_password';
  static const String _deviceTokenKey = 'mwpa_device_token';

  final FlutterSecureStorage _storage;

  CredentialStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// readPassword - the stored password or null; a password an older app
  /// version left in shared_preferences is moved into the secure storage on
  /// the first read. A secure storage that can't be decrypted (e.g. restored
  /// from a backup onto another device) reads as "no password", the user
  /// then simply signs in again.
  Future<String?> readPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(Preference.PASSWORD);

    if (legacy != null) {
      try {
        await _storage.write(key: _passwordKey, value: legacy);
        await prefs.remove(Preference.PASSWORD);
      } catch (error) {
        // keep the legacy value, the move is retried with the next read
        AppLog.e('Credentials', error);
      }

      return legacy;
    }

    try {
      return await _storage.read(key: _passwordKey);
    } catch (error) {
      AppLog.e('Credentials', error);

      return null;
    }
  }

  /// writePassword
  Future<void> writePassword(String password) async {
    await _storage.write(key: _passwordKey, value: password);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Preference.PASSWORD);
  }

  /// deletePassword - on logout and when a Quick Connect session replaces
  /// the password login
  Future<void> deletePassword() async {
    try {
      await _storage.delete(key: _passwordKey);
    } catch (error) {
      AppLog.e('Credentials', error);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Preference.PASSWORD);
  }

  /// readDeviceToken - the Quick Connect device token or null (also when the
  /// secure storage can't be decrypted, the user then connects again)
  Future<String?> readDeviceToken() async {
    try {
      return await _storage.read(key: _deviceTokenKey);
    } catch (error) {
      AppLog.e('Credentials', error);

      return null;
    }
  }

  /// writeDeviceToken
  Future<void> writeDeviceToken(String token) async {
    await _storage.write(key: _deviceTokenKey, value: token);
  }

  /// deleteDeviceToken - on logout and when a password login replaces the
  /// Quick Connect session
  Future<void> deleteDeviceToken() async {
    try {
      await _storage.delete(key: _deviceTokenKey);
    } catch (error) {
      AppLog.e('Credentials', error);
    }
  }
}
