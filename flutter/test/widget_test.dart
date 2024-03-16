// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_otp/main.dart';

void main() {
  testWidgets('Opening an empty database', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Unlock Database'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    expect(find.byIcon(Icons.block), findsNothing);
    expect(find.byType(ElevatedButton), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();// handle the route push
    expect(find.text('Unlock Database'), findsOneWidget);
    expect(find.byIcon(Icons.block), findsNothing);
    await tester.pump();// handle the new route
    expect(find.byIcon(Icons.block), findsOneWidget);
  });
}
