import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/SyncController.dart';
import 'package:mwpaapp/Services/SyncMwpaService.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Fake {
  final net = StreamController<List<ConnectivityResult>>.broadcast();
  bool online = true;
  int pending = 1;
  int runs = 0;
  Object? fail;
  Completer<void>? gate;
  DateTime now = DateTime(2026, 11, 6, 10);

  late final PrefController prefs = PrefController()..isLogin = true;

  late final SyncController controller = SyncController(
    prefs: prefs,
    runSync: (update) async {
      runs++;
      await update(50, SyncStep.sightings);
      if (gate != null) await gate!.future;
      if (fail != null) throw fail!;
    },
    afterSync: () async {},
    pendingCount: () async => pending,
    connectivityChanges: net.stream,
    checkConnectivity: () async => [online ? ConnectivityResult.wifi : ConnectivityResult.none],
    now: () => now,
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('auto sync runs when online, logged in and something is open', () async {
    final f = _Fake();
    await f.controller.autoSync('test');

    expect(f.runs, 1);
    expect(f.controller.lastSync, f.now);
    expect((await SharedPreferences.getInstance()).getString(Preference.LAST_SYNC), isNotNull);
  });

  test('no auto sync offline, logged out or with nothing to do', () async {
    final f = _Fake()..online = false;
    await f.controller.autoSync('test');
    expect(f.runs, 0);

    f
      ..online = true
      ..prefs.isLogin = false;
    await f.controller.autoSync('test');
    expect(f.runs, 0);

    // nothing open, but the reference data is never synced: stale -> sync
    f
      ..prefs.isLogin = true
      ..pending = 0;
    await f.controller.autoSync('test');
    expect(f.runs, 1);

    // nothing open and fresh -> no sync
    f.now = f.now.add(const Duration(hours: 1));
    await f.controller.autoSync('test');
    expect(f.runs, 1);

    // data older than refreshAfter -> sync
    f.now = f.now.add(SyncController.refreshAfter);
    await f.controller.autoSync('test');
    expect(f.runs, 2);
  });

  test('no auto sync while an edit page holds it, catches up on release', () async {
    final f = _Fake();
    f.controller.hold();
    await f.controller.autoSync('test');
    expect(f.runs, 0);

    f.controller.release();
    await pumpEventQueue();
    expect(f.runs, 1);
  });

  test('manual sync joins a running one instead of starting a second', () async {
    final f = _Fake()..gate = Completer<void>();
    final first = f.controller.syncNow();
    final second = f.controller.syncNow();
    expect(f.controller.running, isTrue);

    await pumpEventQueue();
    expect(f.controller.percent, 50);
    expect(f.controller.step, SyncStep.sightings);

    f.gate!.complete();
    expect(await first, isNull);
    expect(await second, isNull);
    expect(f.runs, 1);
    expect(f.controller.running, isFalse);
  });

  test('missing credentials stop the automatic sync until a manual one', () async {
    final f = _Fake()..fail = const MissingCredentialsException('no password');

    expect(await f.controller.syncNow(), isA<MissingCredentialsException>());
    expect(f.controller.autoStopped, isTrue);

    await f.controller.autoSync('test');
    expect(f.runs, 1);

    f.fail = null;
    expect(await f.controller.syncNow(), isNull);
    expect(f.controller.autoStopped, isFalse);
    expect(f.controller.lastError, isNull);
  });

  test('a refused login stops the automatic sync too', () async {
    final f = _Fake()..fail = const LoginRejectedException('user@example.org');

    expect(await f.controller.syncNow(), isA<LoginRejectedException>());
    expect(f.controller.autoStopped, isTrue);
  });

  test('network errors keep the automatic sync on (retry)', () async {
    final f = _Fake()..fail = Exception('Connection failed');

    expect(await f.controller.syncNow(), isNotNull);
    expect(f.controller.autoStopped, isFalse);
    expect(f.controller.lastError, isNotNull);
    f.controller.dispose();
  });

  test('network coming back triggers a sync', () async {
    final f = _Fake();
    await f.controller.start(firstCheckAfter: const Duration(hours: 1));

    f.net.add([ConnectivityResult.mobile]);
    await pumpEventQueue();
    expect(f.runs, 1);
    f.controller.dispose();
  });

  test('syncAfterLogin syncs right away, also before the login flag is loaded', () async {
    // right after the login the PrefController is not reloaded yet and the
    // previous user stopped the automatic sync
    final f = _Fake()..pending = 0;
    f.prefs.isLogin = false;
    f.controller.autoStopped = true;

    expect(await f.controller.syncAfterLogin(), isNull);
    expect(f.runs, 1);
    expect(f.controller.autoStopped, isFalse);
    expect(f.controller.lastSync, f.now);
  });
}
