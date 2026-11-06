import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/main.dart';

void main() {
  PrefController prefs({required bool disclosure, required bool login}) => PrefController()
    ..prominentDisclosureConfirmed = disclosure
    ..isLogin = login;

  test('disclosure first, then list or login', () {
    expect(MWPAApp.initialRoute(prefs(disclosure: false, login: true)), '/ProminentDisclosure');
    expect(MWPAApp.initialRoute(prefs(disclosure: true, login: true)), '/List');
    expect(MWPAApp.initialRoute(prefs(disclosure: true, login: false)), '/Login');
  });
}
