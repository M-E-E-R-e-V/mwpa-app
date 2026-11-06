import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mwpaapp/Mwpa/MwpaAPI.dart';
import 'package:mwpaapp/Mwpa/MwpaException.dart';

http.Response _json(Object body, {Map<String, String> headers = const {}}) =>
    http.Response(jsonEncode(body), 200, headers: headers);

void main() {
  const server = 'https://mwpa.example';

  group('MwpaApi', () {
    test('getInfo is sent without cookie and returns the versions', () async {
      late http.Request seen;

      final api = MwpaApi(server, client: MockClient((request) async {
        seen = request;
        return _json({'statusCode': 200, 'version_api_login': '1', 'version_api_sync': '1'});
      }));

      final info = await api.getInfo();

      expect(seen.method, 'GET');
      expect(seen.url.toString(), '$server/mobile/info');
      expect(seen.headers.containsKey('cookie'), isFalse);
      expect(info.version_api_sync, '1');
    });

    test('login stores the session cookie and sends it afterwards', () async {
      final requests = <http.Request>[];

      final api = MwpaApi(server, client: MockClient((request) async {
        requests.add(request);

        return switch (request.url.path) {
          '/mobile/login' => _json({'success': true}, headers: {'set-cookie': 'sid=abc'}),
          '/mobile/islogin' => _json({'status': true}),
          '/mobile/vehicle/list' => _json({
              'statusCode': 200,
              'list': [{'id': 3, 'name': 'Boat', 'isdeleted': 0}],
            }),
          _ => http.Response('not found', 404),
        };
      }));

      expect(await api.login('a@b.c', 'secret'), isTrue);

      final loginBody = jsonDecode(requests.first.body) as Map<String, dynamic>;
      expect(requests.first.method, 'POST');
      expect(loginBody['email'], 'a@b.c');
      expect(loginBody['password'], 'secret');
      expect(loginBody.containsKey('deviceIdentity'), isTrue);

      expect(await api.isLogin(), isTrue);
      final vehicles = await api.getVehicleList();

      expect(vehicles.single.name, 'Boat');
      expect(requests[1].headers['cookie'], 'sid=abc');
      expect(requests[2].headers['cookie'], 'sid=abc');
    });

    test('a refused login throws the server message as MwpaException', () async {
      final api = MwpaApi(server, client: MockClient((_) async =>
          _json({'success': false, 'error': 'Wrong password'})));

      await expectLater(
        api.login('a@b.c', 'x'),
        throwsA(isA<MwpaException>().having((e) => e.toString(), 'message', 'Wrong password')),
      );
    });

    test('list getters require a login', () async {
      final api = MwpaApi(server, client: MockClient((_) async => _json({})));

      await expectLater(api.getSpeciesList(), throwsA(isA<MwpaException>()));
    });

    test('a status code other than OK throws the server message', () async {
      final api = MwpaApi(server, client: MockClient((request) async =>
          request.url.path == '/mobile/islogin'
              ? _json({'status': true})
              : _json({'statusCode': 401, 'msg': 'Session expired'})));

      await api.isLogin();

      await expectLater(
        api.getVehicleDriverList(),
        throwsA(isA<MwpaException>().having((e) => e.toString(), 'message', 'Session expired')),
      );
    });

    test('saveSightingTourTracking returns false when not OK', () async {
      final api = MwpaApi(server, client: MockClient((_) async => _json({'statusCode': 500})));

      expect(await api.saveSightingTourTracking([]), isFalse);
    });

    test('network failures become a connection error', () async {
      final api = MwpaApi(server, client: MockClient((_) async =>
          throw http.ClientException('Connection refused')));

      await expectLater(
        api.getInfo(),
        throwsA(isA<Exception>()
            .having((e) => e is MwpaException, 'is MwpaException', isFalse)
            .having((e) => e.toString(), 'message', contains('Connection error'))),
      );
    });

    test('broken JSON becomes a connection error', () async {
      final api = MwpaApi(server, client: MockClient((_) async => http.Response('<html>', 502)));

      await expectLater(
        api.isLogin(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Connection error'))),
      );
    });

    test('a server that does not answer times out', () async {
      final never = Completer<http.Response>();
      final api = MwpaApi(
        server,
        client: MockClient((_) => never.future),
        timeout: const Duration(milliseconds: 50),
      );

      await expectLater(
        api.getInfo(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('timeout'))),
      );
    });

    test('image calls return false for a missing file without a request', () async {
      var calls = 0;
      final api = MwpaApi(server, client: MockClient((_) async {
        calls++;
        return _json({'statusCode': 200, 'isExist': true});
      }));

      expect(await api.existSightingImage('u1', '/does/not/exist.jpg'), isFalse);
      expect(await api.saveSightingImage('u1', '/does/not/exist.jpg'), isFalse);
      expect(calls, 0);
    });
  });
}
