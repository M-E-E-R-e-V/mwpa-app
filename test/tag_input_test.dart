import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Components/TagInput.dart';

void main() {
  late List<String> reported;

  Future<void> pump(WidgetTester tester,
      {List<String> initial = const [], List<String> suggestions = const []}) async {
    reported = initial;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TagInput(
          initialTags: initial,
          suggestions: suggestions,
          onChanged: (tags) => reported = tags,
        ),
      ),
    ));
  }

  testWidgets('shows initial tags as chips', (tester) async {
    await pump(tester, initial: ['SLP', ' ', 'SPY']);

    expect(find.byType(InputChip), findsNWidgets(2));
    expect(find.text('SLP'), findsOneWidget);
  });

  testWidgets('adds a tag on Enter and on separator, ignores duplicates', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), 'whale');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(reported, ['whale']);

    await tester.enterText(find.byType(TextField), 'dolphin,');
    await tester.pump();
    expect(reported, ['whale', 'dolphin']);

    await tester.enterText(find.byType(TextField), 'whale ');
    await tester.pump();
    expect(reported, ['whale', 'dolphin']);
    expect(find.byType(InputChip), findsNWidgets(2));
  });

  testWidgets('removes a tag via the chip delete icon', (tester) async {
    await pump(tester, initial: ['SLP', 'SPY']);

    await tester.tap(find.byTooltip('Delete').first);
    await tester.pump();

    expect(reported, ['SPY']);
  });

  testWidgets('adds a picked suggestion (case-insensitive match)', (tester) async {
    await pump(tester, suggestions: ['Test', 'SLP', 'SPY']);

    await tester.enterText(find.byType(TextField), 'sl');
    await tester.pumpAndSettle();
    await tester.tap(find.text('SLP'));
    await tester.pumpAndSettle();

    expect(reported, ['SLP']);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
  });
}
