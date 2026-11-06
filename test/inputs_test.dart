import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mwpaapp/Components/Inputs/Inputs.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/l10n/l10n.dart';
import 'package:provider/provider.dart';

Future<void> pumpInput(WidgetTester tester, Widget input, {LocationController? location}) {
  Widget app = MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: input)),
  );

  if (location != null) {
    app = ChangeNotifierProvider<LocationController>.value(value: location, child: app);
  }

  return tester.pumpWidget(app);
}

Position _pos({double accuracy = 12.7}) => Position(
      latitude: 28.1, longitude: -17.3, timestamp: DateTime(2026, 6, 8),
      accuracy: accuracy, altitude: 0, altitudeAccuracy: 0, heading: 0,
      headingAccuracy: 0, speed: 0, speedAccuracy: 0);

final _items = [
  DynInputSelectItem(value: '1', label: 'Boat A'),
  DynInputSelectItem(value: '2', label: 'Boat B'),
];

/// text shown in the (single) DropdownMenu field
String _menuText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  group('SelectInput', () {
    testWidgets('shows label, unknown id, placeholder and empty list', (tester) async {
      final value = DynInputValue()..strValue = '2';
      await pumpInput(tester, SelectInput(title: 'Boat', value: value, items: _items));
      expect(find.text('Boat'), findsOneWidget);
      expect(_menuText(tester), 'Boat B');

      await pumpInput(tester, SelectInput(value: DynInputValue()..strValue = '9', items: _items));
      expect(find.text('unknown by id: 9'), findsOneWidget);

      await pumpInput(tester, SelectInput(value: DynInputValue(), items: _items));
      expect(find.text('<please select>'), findsOneWidget);

      await pumpInput(tester, SelectInput(value: DynInputValue(), items: const []));
      expect(find.text('<empty list>'), findsOneWidget);
    });

    testWidgets('selecting an item stores its value and notifies', (tester) async {
      final value = DynInputValue();
      var changed = 0;
      await pumpInput(tester, SelectInput(value: value, items: _items, onChange: () => changed++));

      await tester.tap(find.byType(DropdownMenu<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Boat A').last);
      await tester.pumpAndSettle();

      expect(value.strValue, '1');
      expect(changed, 1);
      expect(_menuText(tester), 'Boat A');
    });

    testWidgets('long lists can be filtered by typing', (tester) async {
      final many = [
        for (var i = 1; i <= SelectInput.searchThreshold; i++) DynInputSelectItem(value: '$i', label: 'Species $i'),
        DynInputSelectItem(value: '13', label: 'Fin Whale'),
      ];
      final value = DynInputValue();
      await pumpInput(tester, SelectInput(value: value, items: many));

      await tester.tap(find.byType(DropdownMenu<String>));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'fin');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(MenuItemButton, 'Species 1'), findsNothing);
      await tester.tap(find.widgetWithText(MenuItemButton, 'Fin Whale'));
      await tester.pumpAndSettle();

      expect(value.strValue, '13');
    });

    testWidgets('searchable: false keeps a long list a plain dropdown', (tester) async {
      final many = [
        for (var i = 0; i <= 25; i++) DynInputSelectItem(value: '$i', label: '$i'),
      ];
      await pumpInput(tester, SelectInput(value: DynInputValue(), items: many, searchable: false));

      final menu = tester.widget<DropdownMenu<String>>(find.byType(DropdownMenu<String>));
      expect(menu.enableFilter, isFalse);
      expect(menu.requestFocusOnTap, isFalse);
    });
  });

  testWidgets('MultiSelectInput adds and removes selects', (tester) async {
    final value = DynInputValue()..setMultiValue('{"0":"1","1":"2"}');
    await pumpInput(tester, MultiSelectInput(value: value, items: _items));

    expect(find.byType(SelectField), findsNWidgets(2));
    await tester.tap(find.text('Add'));
    await tester.pump();
    expect(find.byType(SelectField), findsNWidgets(3));

    await tester.tap(find.byTooltip('Remove').first);
    await tester.pump();

    expect(find.byType(SelectField), findsNWidgets(2));
    expect(value.getMultiValue(), '{"0":"2","1":""}');
  });

  testWidgets('MultiSelectInput keeps at least one select', (tester) async {
    await pumpInput(tester, MultiSelectInput(value: DynInputValue(), items: _items));

    expect(find.byType(SelectField), findsOneWidget);
    expect(find.byTooltip('Remove'), findsNothing);
  });

  testWidgets('SwitchInput toggles intValue 0/1', (tester) async {
    final value = DynInputValue();
    var changed = 0;
    await pumpInput(tester, SwitchInput(title: 'Photos', value: value, onChange: () => changed++));

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(value.intValue, 1);

    // the whole tile toggles, not only the switch
    await tester.tap(find.text('Photos'));
    await tester.pump();
    expect(value.intValue, 0);
    expect(changed, 2);
  });

  testWidgets('YesNoUnknownInput maps Unknown/Yes/No to -1/1/0', (tester) async {
    final value = DynInputValue();
    await pumpInput(tester, YesNoUnknownInput(value: value));

    for (final (label, expected) in [('Yes', 1), ('No', 0), ('Unknown', -1)]) {
      await tester.tap(find.text(label));
      await tester.pump();
      expect(value.intValue, expected, reason: label);

      final buttons = tester.widget<SegmentedButton<int>>(find.byType(SegmentedButton<int>));
      expect(buttons.selected, {expected});
    }
  });

  testWidgets('DateInput and TimeInput show the stored value', (tester) async {
    final date = DynInputValue()..dateValue = DateTime(2026, 6, 8);
    final time = DynInputValue()..setTimeOfDy('09:05');

    await pumpInput(tester, Column(children: [
      DateInput(value: date),
      TimeInput(value: time),
      TimeInput(value: DynInputValue()),
    ]));

    expect(find.text('6/8/2026'), findsOneWidget);
    expect(find.text('9:05 AM'), findsOneWidget);
  });

  group('LocationInput', () {
    late LocationController location;

    setUp(() => location = LocationController(PrefController(), SightingController()));

    testWidgets('shows the accuracy of a stored position', (tester) async {
      final value = DynInputValue()..posValue = _pos();
      await pumpInput(tester, LocationInput(title: 'Position begin', value: value), location: location);

      expect(find.text('Position begin'), findsOneWidget);
      expect(find.text('Accuracy: 12 m'), findsOneWidget);
    });

    testWidgets('takes over the current position, no crash without GPS fix', (tester) async {
      final value = DynInputValue();
      var changed = 0;
      await pumpInput(tester, LocationInput(value: value, onChange: () => changed++), location: location);

      await tester.tap(find.byTooltip('Use current position'));
      await tester.pump();
      expect(value.posValue, isNull);
      expect(changed, 0);
      expect(find.text('No GPS position available yet'), findsOneWidget);

      location.currentPosition = _pos(accuracy: 5);
      await tester.tap(find.byTooltip('Use current position'));
      await tester.pump();
      expect(value.posValue!.accuracy, 5);
      expect(changed, 1);
    });
  });

  group('TextValueInput', () {
    testWidgets('shows the stored value as text and stores typed text', (tester) async {
      final value = DynInputValue()..strValue = '7';
      await pumpInput(tester, TextValueInput(value: value, kind: TextValueKind.digits));

      expect(find.text('7'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '12a.3');
      expect(value.strValue, '123');
    });

    testWidgets('decimal accepts point and comma only', (tester) async {
      final value = DynInputValue();
      await pumpInput(tester, TextValueInput(value: value, kind: TextValueKind.decimal));

      await tester.enterText(find.byType(TextField), '3,5x');
      expect(value.strValue, '3,5');
    });

    testWidgets('textarea shows the stored value as editable text', (tester) async {
      final value = DynInputValue()..strValue = 'calm sea';
      await pumpInput(tester, TextValueInput(value: value, kind: TextValueKind.textarea));

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'calm sea');
    });
  });

  group('DistanceInput', () {
    testWidgets('shows stored meters as nm and stores typed nm as meters', (tester) async {
      final value = DynInputValue()..strValue = '9260';
      await pumpInput(tester, DistanceInput(value: value));

      expect(find.text('5.0'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '2,5');
      expect(value.strValue, '4630');

      await tester.enterText(find.byType(TextField), '');
      expect(value.strValue, '');
    });

    testWidgets('invalid input shows an error and keeps the last value', (tester) async {
      final value = DynInputValue()..strValue = '1852';
      await pumpInput(tester, DistanceInput(value: value));

      await tester.enterText(find.byType(TextField), '1.2.3');
      await tester.pump();

      expect(find.text('Not a valid number'), findsOneWidget);
      expect(value.strValue, '1852');
    });

    testWidgets('follows meters changed by the page', (tester) async {
      final value = DynInputValue()..strValue = '1852';
      await pumpInput(tester, DistanceInput(value: value));

      value.strValue = '3704';
      await pumpInput(tester, DistanceInput(value: value));

      expect(find.text('2.0'), findsOneWidget);
    });
  });

  group('TagInput', () {
    test('parseTags reads JSON lists and legacy space separated strings', () {
      expect(TagInput.parseTags(''), isEmpty);
      expect(TagInput.parseTags('["SLP","SPY"]'), ['SLP', 'SPY']);
      expect(TagInput.parseTags('SLP SPY'), ['SLP', 'SPY']);
    });

    testWidgets('stores tags as JSON list', (tester) async {
      final value = DynInputValue()..strValue = 'SLP';
      await pumpInput(tester, TagInput(value: value));

      await tester.enterText(find.byType(TextField), 'SPY,');
      await tester.pump();

      expect(jsonDecode(value.strValue), ['SLP', 'SPY']);
    });
  });

  testWidgets('ImageInput without image shows placeholder', (tester) async {
    await pumpInput(tester, ImageInput(title: 'Photo', value: DynInputValue()));

    expect(find.text('No image selected'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.byTooltip('Remove image'), findsNothing);
  });
}
