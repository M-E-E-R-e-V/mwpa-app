import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mwpaapp/Components/Inputs/Inputs.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:provider/provider.dart';

Future<void> pumpInput(WidgetTester tester, Widget input, {LocationController? location}) {
  Widget app = MaterialApp(home: Scaffold(body: SingleChildScrollView(child: input)));

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

void main() {
  group('SelectInput', () {
    testWidgets('shows label, unknown id, placeholder and empty list', (tester) async {
      final value = DynInputValue()..strValue = '2';
      await pumpInput(tester, SelectInput(title: 'Boat', value: value, items: _items));
      expect(find.text('Boat'), findsOneWidget);
      expect(find.text('Boat B'), findsOneWidget);

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

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Boat A').last);
      await tester.pumpAndSettle();

      expect(value.strValue, '1');
      expect(changed, 1);
      expect(find.text('Boat A'), findsOneWidget);
    });
  });

  testWidgets('MultiSelectInput starts with one select and adds more', (tester) async {
    final value = DynInputValue();
    await pumpInput(tester, MultiSelectInput(value: value, items: _items));

    expect(find.byType(SelectInput), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump();

    expect(find.byType(SelectInput), findsNWidgets(2));
    expect(value.multiValue, hasLength(2));
  });

  testWidgets('SwitchInput toggles intValue 0/1', (tester) async {
    final value = DynInputValue();
    var changed = 0;
    await pumpInput(tester, SwitchInput(value: value, onChange: () => changed++));

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(value.intValue, 1);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(value.intValue, 0);
    expect(changed, 2);
  });

  testWidgets('YesNoUnknownInput maps Unknown/Yes/No to -1/1/0', (tester) async {
    final value = DynInputValue();
    await pumpInput(tester, YesNoUnknownInput(value: value));

    for (final (label, expected) in [('Unknown', -1), ('Yes', 1), ('No', 0)]) {
      await tester.tap(find.text(' $label '));
      await tester.pump();
      expect(value.intValue, expected, reason: label);

      final buttons = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
      expect(buttons.isSelected.where((s) => s), hasLength(1));
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

    testWidgets('shows accuracy in the title when a position is stored', (tester) async {
      final value = DynInputValue()..posValue = _pos();
      await pumpInput(tester, LocationInput(title: 'Position begin', value: value), location: location);

      expect(find.text('Position begin (accuracy: 12 m)'), findsOneWidget);
    });

    testWidgets('takes over the current position, no crash without GPS fix', (tester) async {
      final value = DynInputValue();
      var changed = 0;
      await pumpInput(tester, LocationInput(value: value, onChange: () => changed++), location: location);

      await tester.tap(find.byIcon(Icons.edit_location));
      await tester.pump();
      expect(value.posValue, isNull);
      expect(changed, 0);

      location.currentPosition = _pos(accuracy: 5);
      await tester.tap(find.byIcon(Icons.edit_location));
      await tester.pump();
      expect(value.posValue!.accuracy, 5);
      expect(changed, 1);
    });
  });

  group('TextValueInput', () {
    testWidgets('decimal shows formatted value as hint and stores typed text', (tester) async {
      final value = DynInputValue()..strValue = '1852';
      await pumpInput(tester, TextValueInput(
        value: value,
        kind: TextValueKind.decimal,
        onFormat: (v) => 'formatted ${v.strValue}',
      ));

      expect(find.text('formatted 1852'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '3.5');
      expect(value.strValue, '3.5');
    });

    testWidgets('digits accepts only digits', (tester) async {
      final value = DynInputValue();
      await pumpInput(tester, TextValueInput(value: value, kind: TextValueKind.digits));

      await tester.enterText(find.byType(TextFormField), '12a.3');
      expect(value.strValue, '123');
    });

    testWidgets('textarea shows the stored value as editable text', (tester) async {
      final value = DynInputValue()..strValue = 'calm sea';
      await pumpInput(tester, TextValueInput(value: value, kind: TextValueKind.textarea));

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'calm sea');
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
    expect(find.byIcon(Icons.camera), findsOneWidget);
  });
}
