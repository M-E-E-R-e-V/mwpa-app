import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Settings/CredentialStore.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('write / read / delete', () async {
    final store = CredentialStore();

    expect(await store.readPassword(), isNull);

    await store.writePassword('secret');
    expect(await store.readPassword(), 'secret');

    await store.deletePassword();
    expect(await store.readPassword(), isNull);
  });

  test('a password from shared_preferences is moved to the secure storage', () async {
    SharedPreferences.setMockInitialValues({Preference.PASSWORD: 'old'});
    final store = CredentialStore();

    expect(await store.readPassword(), 'old');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(Preference.PASSWORD), isFalse);
    expect(await const FlutterSecureStorage().read(key: 'mwpa_password'), 'old');
    expect(await store.readPassword(), 'old');
  });

  test('writing removes a leftover plain-text password', () async {
    SharedPreferences.setMockInitialValues({Preference.PASSWORD: 'old'});

    await CredentialStore().writePassword('new');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(Preference.PASSWORD), isFalse);
    expect(await CredentialStore().readPassword(), 'new');
  });

  test('logout deletes the legacy value too', () async {
    SharedPreferences.setMockInitialValues({Preference.PASSWORD: 'old'});

    await CredentialStore().deletePassword();

    expect(await CredentialStore().readPassword(), isNull);
  });
}
