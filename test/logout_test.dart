import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('logout removes session, tour and home area tour, keeps url/username/consent', () async {
    const tour = '{"vehicle_id":1,"vehicle_driver_id":2,"date":"2026-11-05","tour_start":"08:00"}';

    SharedPreferences.setMockInitialValues({
      Preference.URL: 'https://mwpa.example/',
      Preference.USERNAME: 'guide@example.org',
      Preference.USERID: 7,
      Preference.ORGID: 3,
      Preference.TOUR: tour,
      Preference.HOME_AREA_TOUR: tour,
      Preference.PROMINENT_DISCLOSURE_CONFIRMED: true,
    });

    final pref = PrefController();
    await pref.load();

    expect(pref.isLogin, isTrue);
    expect(pref.prefToru, isNotNull);
    expect(pref.homeAreaTour, isNotNull);

    await pref.logout();

    expect(pref.isLogin, isFalse);
    expect(pref.prefToru, isNull);
    expect(pref.homeAreaTour, isNull);
    expect(pref.prominentDisclosureConfirmed, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {
      Preference.URL,
      Preference.USERNAME,
      Preference.PROMINENT_DISCLOSURE_CONFIRMED,
    });

    // a fresh load (app restart) sees the logged-out state
    final reloaded = PrefController();
    await reloaded.load();
    expect(reloaded.isLogin, isFalse);
    expect(reloaded.prefToru, isNull);
  });
}
