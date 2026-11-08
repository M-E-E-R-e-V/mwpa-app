import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mwpaapp/Mwpa/Models/CoastlineResponse.dart';
import 'package:mwpaapp/Mwpa/MwpaAPI.dart';
import 'package:mwpaapp/Services/SyncMwpaService.dart';
import 'package:mwpaapp/Util/UtilDistanceCoast.dart';

http.Response _json(Object body, {Map<String, String> headers = const {}}) =>
    http.Response(jsonEncode(body), 200, headers: headers);

Position _pos(double lat, double lon) => Position(
      latitude: lat,
      longitude: lon,
      timestamp: DateTime(2026, 11, 8),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

/// box 28.0..28.2 / -17.4..-17.2 with a straight north-south coast at
/// lon -17.3 from 28.05 to 28.15
CoastlineData _data({String status = 'ok', List<List<double>>? lines}) => CoastlineData(
      status: status,
      areaKey: 'org:1:box',
      south: 28.0,
      west: -17.4,
      north: 28.2,
      east: -17.2,
      lines: lines ?? [
        [28.05, -17.3, 28.15, -17.3],
      ],
      fetchDatetime: 1000,
    );

const int t0 = 1800000000;

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('coast');
    await UtilDistanceCoast.init(dir: dir);
  });

  tearDown(() => dir.delete(recursive: true));

  group('CoastLines.distanceMeters', () {
    final coast = CoastLines(_data());

    test('distance to the line, not to its points', () {
      // 0.01° east of the line at 28.1: 0.01 * 111320 * cos(28.1°) = 982 m
      expect(coast.distanceMeters(28.1, -17.29)!, closeTo(982, 3));
      // beyond the end of the line: distance to the end point (1113 m north)
      expect(coast.distanceMeters(28.16, -17.3)!, closeTo(1113, 3));
    });

    test('outside the box or a nearer coast possible outside: null', () {
      expect(coast.distanceMeters(28.3, -17.3), isNull);
      // 0.07° (~6.9 km) from the line, but only ~2.9 km from the east edge
      expect(coast.distanceMeters(28.1, -17.23), isNull);
      expect(CoastLines(_data(lines: [])).distanceMeters(28.1, -17.3), isNull);
    });
  });

  group('UtilDistanceCoast', () {
    test('without coast lines from the server: the old La Gomera points', () {
      expect(UtilDistanceCoast.coast, isNull);
      expect(UtilDistanceCoast.getDistance(_pos(28.08, -17.34)), isNotNull);
    });

    test('store keeps the lines across a restart; distance text is empty outside', () async {
      expect(UtilDistanceCoast.needsCheck(t0), isTrue);
      await UtilDistanceCoast.store(t0, _data());
      expect(UtilDistanceCoast.needsCheck(t0 + 3600), isFalse);
      expect(UtilDistanceCoast.needsCheck(t0 + UtilDistanceCoast.checkIntervalSec), isTrue);

      await UtilDistanceCoast.init(dir: dir);
      expect(UtilDistanceCoast.coast?.data.areaKey, 'org:1:box');
      expect(UtilDistanceCoast.needsCheck(t0 + 3600), isFalse);
      expect(double.parse(UtilDistanceCoast.distanceText(_pos(28.1, -17.29))), closeTo(982, 3));
      expect(UtilDistanceCoast.distanceText(_pos(37.4, -122.08)), '');

      // a check without new lines keeps the old ones
      await UtilDistanceCoast.store(t0 + 4000);
      expect(UtilDistanceCoast.coast?.data.areaKey, 'org:1:box');
    });
  });

  group('SyncMwpaService.syncCoastline', () {
    Future<MwpaApi> api(http.Response Function(http.Request request) coastline, List<http.Request> seen) async {
      final api = MwpaApi('https://mwpa.example', client: MockClient((request) async {
        if (request.url.path == '/mobile/login') {
          return _json({'success': true}, headers: {'set-cookie': 'sid=abc'});
        }

        if (request.url.path == '/mobile/islogin') {
          return _json({'status': true});
        }

        seen.add(request);
        return coastline(request);
      }));

      await api.login('a@b.c', 'secret');
      await api.isLogin();
      return api;
    }

    Map<String, dynamic> answer(CoastlineData data) => {'statusCode': 200, 'data': data.toJson()};

    test('ok: lines stored, position sent, no second request the same day', () async {
      final seen = <http.Request>[];
      final client = await api((_) => _json(answer(_data())), seen);

      await SyncMwpaService.syncCoastline(client, lastPosition: () async => _pos(28.1, -17.3), nowSec: t0);
      await SyncMwpaService.syncCoastline(client, lastPosition: () async => null, nowSec: t0 + 1000);

      expect(seen, hasLength(1));
      expect(seen.single.method, 'POST');
      expect(jsonDecode(seen.single.body), {'latitude': 28.1, 'longitude': -17.3});
      expect(UtilDistanceCoast.coast?.data.lines, hasLength(1));
    });

    test('pending: asked again with the next sync', () async {
      final seen = <http.Request>[];
      final client = await api((_) => _json(answer(_data(status: 'pending', lines: []))), seen);

      await SyncMwpaService.syncCoastline(client, lastPosition: () async => null, nowSec: t0);
      await SyncMwpaService.syncCoastline(client, lastPosition: () async => null, nowSec: t0 + 100);

      expect(seen, hasLength(2));
      expect(jsonDecode(seen.first.body), <String, dynamic>{});
      expect(UtilDistanceCoast.coast, isNull);
    });

    test('older server without the endpoint (404) and errors never fail the sync', () async {
      final seen = <http.Request>[];
      final old = await api((_) => http.Response('not found', 404), seen);

      await SyncMwpaService.syncCoastline(old, lastPosition: () async => null, nowSec: t0);
      expect(UtilDistanceCoast.coast, isNull);
      expect(UtilDistanceCoast.needsCheck(t0 + 100), isFalse);

      final broken = await api((_) => http.Response('<html>', 502), seen);
      await SyncMwpaService.syncCoastline(broken, lastPosition: () => throw StateError('no permission'), nowSec: t0 + 999999);
      expect(UtilDistanceCoast.coast, isNull);
    });
  });
}
