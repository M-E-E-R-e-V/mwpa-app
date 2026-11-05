import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Services/SyncMwpaService.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/AppLog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SyncController - runs the sync with the MWPA server, by hand (menu, pull
/// to refresh) and automatically in the background:
///
/// - on app start, when the network comes back and every [checkInterval],
/// - only when logged in, online and something is open (or the reference
///   data is older than [refreshAfter]),
/// - never while an edit page is open ([hold]/[release]): the page keeps the
///   sighting it edits, a sync in between would be overwritten by its save,
/// - after a failure it retries with [retryDelays]; missing credentials or an
///   incompatible server stop the automatic sync until the next manual one.
class SyncController extends ChangeNotifier {
  static const Duration checkInterval = Duration(minutes: 15);
  static const Duration refreshAfter = Duration(hours: 6);
  static const List<Duration> retryDelays = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
  ];

  final PrefController _prefs;
  final Future<void> Function(SyncUpdate update) _runSync;
  final Future<void> Function() _afterSync;
  final Future<int> Function() _pendingCount;
  final Stream<List<ConnectivityResult>> _connectivityChanges;
  final Future<List<ConnectivityResult>> Function() _checkConnectivity;
  final DateTime Function() _now;

  SyncController({
    required PrefController prefs,
    required Future<void> Function(SyncUpdate update) runSync,
    required Future<void> Function() afterSync,
    required Future<int> Function() pendingCount,
    Stream<List<ConnectivityResult>>? connectivityChanges,
    Future<List<ConnectivityResult>> Function()? checkConnectivity,
    DateTime Function()? now,
  })  : _prefs = prefs,
        _runSync = runSync,
        _afterSync = afterSync,
        _pendingCount = pendingCount,
        _connectivityChanges = connectivityChanges ?? Connectivity().onConnectivityChanged,
        _checkConnectivity = checkConnectivity ?? Connectivity().checkConnectivity,
        _now = now ?? DateTime.now;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _intervalTimer;
  Timer? _retryTimer;
  Future<Object?>? _running;
  int _holds = 0;
  bool _missedWhileHeld = false;
  int _failures = 0;

  /// a sync is running
  bool get running => _running != null;

  /// progress of the running sync
  int percent = 0;
  SyncStep? step;
  String? detail;

  /// end of the last successful sync (persisted)
  DateTime? lastSync;

  /// error of the last sync, null after a successful one
  Object? lastError;

  /// automatic sync stopped (credentials missing, incompatible server)
  bool autoStopped = false;

  /// start - restores [lastSync] and starts the automatic triggers
  Future<void> start({Duration firstCheckAfter = const Duration(seconds: 5)}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(Preference.LAST_SYNC);
      lastSync = stored == null ? null : DateTime.tryParse(stored);
    } catch (error) {
      AppLog.w('Sync', 'last sync not readable', error);
    }

    notifyListeners();

    _subscription = _connectivityChanges.listen((results) {
      if (_online(results)) {
        autoSync('network');
      }
    });
    _intervalTimer = Timer.periodic(checkInterval, (_) => autoSync('interval'));
    _retryTimer = Timer(firstCheckAfter, () => autoSync('start'));
  }

  /// reset - logout: forget the state of the previous user
  void reset() {
    _retryTimer?.cancel();
    lastSync = null;
    lastError = null;
    autoStopped = false;
    _failures = 0;
    notifyListeners();
  }

  /// hold - an edit page is open, no automatic sync until [release]
  void hold() => _holds++;

  /// release - edit page closed; catches up a sync that was skipped
  void release() {
    if (_holds > 0) _holds--;

    if (_holds == 0 && _missedWhileHeld) {
      _missedWhileHeld = false;
      autoSync('after edit');
    }
  }

  /// autoSync - runs a background sync if it is allowed and needed
  @visibleForTesting
  Future<void> autoSync(String reason) async {
    if (running || autoStopped || !_prefs.isLogin) {
      return;
    }

    if (_holds > 0) {
      _missedWhileHeld = true;
      return;
    }

    try {
      if (!_online(await _checkConnectivity())) {
        return;
      }

      final pending = await _pendingCount();
      final stale = lastSync == null || _now().difference(lastSync!) >= refreshAfter;

      if (pending == 0 && !stale) {
        return;
      }

      // the checks are async: an edit page may have opened meanwhile
      if (running || _holds > 0) {
        return;
      }

      AppLog.i('Sync', 'auto ($reason): $pending open${stale ? ', data stale' : ''}');
    } catch (error) {
      AppLog.w('Sync', 'auto sync check failed', error);
      return;
    }

    await _run();
  }

  /// syncNow - sync by hand; waits for a running sync instead of starting a
  /// second one. Returns the error or null.
  Future<Object?> syncNow() {
    autoStopped = false;

    return _running ?? _run();
  }

  Future<Object?> _run() {
    _retryTimer?.cancel();

    percent = 0;
    step = null;
    detail = null;

    final future = _execute();
    _running = future;
    notifyListeners();

    return future;
  }

  Future<Object?> _execute() async {
    Object? error;

    try {
      await _runSync((p, s, [d]) async {
        percent = p.clamp(0, 100);
        step = s;
        detail = d;
        notifyListeners();
      });

      await _afterSync();

      lastSync = _now();
      lastError = null;
      _failures = 0;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Preference.LAST_SYNC, lastSync!.toIso8601String());
      } catch (e) {
        AppLog.w('Sync', 'last sync not saved', e);
      }
    } catch (e) {
      error = e;
      lastError = e;

      if (e is MissingCredentialsException || e is LoginRejectedException || e is ApiVersionException) {
        // retrying can't help, the user has to act
        autoStopped = true;
        AppLog.w('Sync', 'automatic sync stopped', e);
      } else {
        final delay = retryDelays[_failures.clamp(0, retryDelays.length - 1)];
        _failures++;
        _retryTimer?.cancel();
        _retryTimer = Timer(delay, () => autoSync('retry'));
      }
    } finally {
      _running = null;
      notifyListeners();
    }

    return error;
  }

  static bool _online(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  void dispose() {
    _subscription?.cancel();
    _intervalTimer?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}
