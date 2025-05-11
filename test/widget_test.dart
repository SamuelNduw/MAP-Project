import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import only your app’s main entrypoint:
import 'package:namibia_hockey_union/main.dart';

void main() {
  testWidgets('AddPlayerPage loads with heading', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NamibiaHockeyApp());

    // Verify that our heading "Enter a Player" shows up:
    expect(find.text('Enter a Player'), findsOneWidget);

    // You could also verify presence of other widgets, e.g. the "+ Image" button:
    expect(find.text('+ Image'), findsOneWidget);
  });
}
