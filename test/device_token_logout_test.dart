import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mwpaapp/Services/SyncMwpaService.dart';
import 'package:mwpaapp/Settings/CredentialStore.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({Preference.URL: 'https://mwpa.example'});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('device token: write / read / delete', () async {
    final store = CredentialStore();

    expect(await store.readDeviceToken(), isNull);
    await store.writeDeviceToken('tok');
    expect(await store.readDeviceToken(), 'tok');
    expect(await store.readPassword(), isNull);
    await store.deleteDeviceToken();
    expect(await store.readDeviceToken(), isNull);
  });

  test('logout revokes the device token and deletes the credentials', () async {
    final paths = <String>[];
    await CredentialStore().writeDeviceToken('tok');

    await SyncMwpaService.clearCredentials(client: MockClient((request) async {
      paths.add(request.url.path);
      return http.Response('{"success":true,"error":""}', 200);
    }));

    expect(paths, ['/mobile/logout/token']);
    expect(await CredentialStore().readDeviceToken(), isNull);
  });

  test('logout offline still deletes the token', () async {
    await CredentialStore().writeDeviceToken('tok');

    await SyncMwpaService.clearCredentials(client: MockClient((_) async => throw Exception('offline')));

    expect(await CredentialStore().readDeviceToken(), isNull);
  });

  test('logout of a password login does not call the server', () async {
    var calls = 0;
    await CredentialStore().writePassword('secret');

    await SyncMwpaService.clearCredentials(client: MockClient((_) async {
      calls++;
      return http.Response('{}', 200);
    }));

    expect(calls, 0);
    expect(await CredentialStore().readPassword(), isNull);
  });
}
