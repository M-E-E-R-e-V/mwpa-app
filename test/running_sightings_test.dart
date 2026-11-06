import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:mwpaapp/Pages/List/RunningSightings.dart';
import 'package:mwpaapp/Util/UtilSighting.dart';
import 'package:mwpaapp/l10n/l10n.dart';
import 'package:provider/provider.dart';

Sighting _s(int id, {String start = '08:30', String? end, String date = '2026-11-05'}) => Sighting(
      unid: '',
      id: id,
      other: 'Animal $id',
      duration_from: '10:0$id',
      vehicle_id: 1,
      vehicle_driver_id: 43,
      date: date,
      tour_start: start,
      location_end: end,
    );

void main() {
  const fid = '1-43-2026-11-05-08:30';

  test('runningSightings: current tour without end position, list order', () {
    final running = UtilSighting.runningSightings([
      _s(5),
      _s(4, end: '{"latitude":1,"longitude":2}'),
      _s(3, end: 'null'),
      _s(2, start: '14:00'),
      _s(1, date: '2026-11-04'),
      _s(0, end: ''),
    ], fid);

    expect(running.map((s) => s.id), [5, 3, 0]);
  });

  test('runningSightings: no tour -> nothing', () {
    expect(UtilSighting.runningSightings([_s(1)], null), isEmpty);
  });

  test('runningSightings: unreadable date is skipped', () {
    expect(UtilSighting.runningSightings([_s(1, date: 'x')], fid), isEmpty);
  });

  test('currentTourFid: default tour, home-area tour, none', () {
    final pref = TourPref(vehicle_id: 1, vehicle_driver_id: 43, date: '2026-11-05', tour_start: '08:30');
    expect(UtilSighting.currentTourFid(prefTour: pref), fid);
    expect(UtilSighting.currentTourFid(), isNull);

    final homePref =
        TourPref(vehicle_id: 1, vehicle_driver_id: 43, date: '2026-11-05', tour_start: '', use_home_area: 1);
    expect(UtilSighting.currentTourFid(prefTour: homePref), isNull);
    expect(
      UtilSighting.currentTourFid(
        prefTour: homePref,
        homeAreaTour: TourPref(date: '2026-11-05', tour_start: '19:37'),
      ),
      '1-43-2026-11-05-19:37',
    );
  });

  test('visibleCount: as many as fit, one slot for "+n more"', () {
    // one label: 36, each further one +42
    expect(RunningSightings.visibleCount(0, 3), 0);
    expect(RunningSightings.visibleCount(36, 1), 1);
    expect(RunningSightings.visibleCount(120, 3), 3);
    expect(RunningSightings.visibleCount(120, 5), 2);
    expect(RunningSightings.visibleCount(120, 0), 0);
  });

  Future<void> pumpLabels(WidgetTester tester, List<Sighting> sightings, double height, {VoidCallback? onShowAll}) {
    final controller = SightingController()..sightingList = sightings;

    return tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: controller),
        ChangeNotifierProvider(create: (_) => SpeciesController()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: height,
              child: RunningSightings(tourFid: fid, onOpen: (_) {}, onShowAll: onShowAll ?? () {}),
            ),
          ),
        ),
      ),
    ));
  }

  testWidgets('labels: name, start time and end button per running sighting', (tester) async {
    await pumpLabels(tester, [_s(1), _s(2, end: '{"latitude":1,"longitude":2}')], 300);

    expect(find.textContaining('Animal 1'), findsOneWidget);
    expect(find.textContaining('10:01'), findsOneWidget);
    expect(find.textContaining('Animal 2'), findsNothing);
    expect(find.byTooltip('Set end location'), findsOneWidget);
  });

  testWidgets('labels: "+n more" when not all fit, opens the list', (tester) async {
    var shown = false;
    await pumpLabels(tester, [for (var i = 1; i <= 5; i++) _s(i)], 120, onShowAll: () => shown = true);

    expect(find.byTooltip('Set end location'), findsNWidgets(2));
    expect(find.text('+3 more'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('+3 more'));
    expect(shown, isTrue);
  });
}
