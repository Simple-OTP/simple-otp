// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:simple_otp/main.dart';
import 'package:simple_otp/provider/configuration.dart';

@GenerateMocks([Configuration])
void main() {
  String? testPath;

  setUp(() async {
    testPath = Directory.systemTemp.createTempSync("test").path;
  });

  tearDown(() async {
    if (testPath == null) {
      return;
    }
    Directory(testPath!).deleteSync(recursive: true);
  });

  testWidgets('Opening an empty database', (WidgetTester tester) async {
    final Configuration configuration = Configuration(testPath!);

    // Build our app and trigger a frame.
    await tester.pumpWidget(OTPProviders(configuration: configuration));

    await tester.pump(); // handle the builder
    // Verify that our counter starts at 0.
    expect(find.text('New Database'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    expect(find.byIcon(Icons.block), findsNothing);
    expect(find.byType(ElevatedButton), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // handle the route push
    expect(find.text('Create'), findsOneWidget);
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Create'), findsNothing); // emoty database
    File file = File('$testPath/tokens.json');
    expect(file.existsSync(), true);
    expect(file.readAsStringSync(), '{"codes":[]}');
  });
}
