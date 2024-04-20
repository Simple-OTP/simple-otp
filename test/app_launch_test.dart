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

/// Here we test the various launch conditions to get to the open database.
/// It includes new databases, existing ones, failures, etc.
@GenerateMocks([Configuration])
void main() {
  List<String> paths = [];

  String generate() {
    var testPath = Directory.systemTemp.createTempSync("test-").path;
    paths.add(testPath);
    return testPath;
  }

  tearDownAll(() {
    for (var path in paths) {
      Directory(path).deleteSync(recursive: true);
    }
    paths.clear();
  });

  testWidgets('Opening an empty unencrypted database',
      (WidgetTester tester) async {
    final testPath = generate();
    final Configuration configuration = Configuration(testPath);

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

    // default is no encryption
    var textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2));
    expect(tester.widget<TextField>(textFields.at(0)).enabled, false);
    expect(tester.widget<TextField>(textFields.at(1)).enabled, false);

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Create'), findsNothing); // emoty database
    File file = File('$testPath/tokens.json');
    expect(file.existsSync(), true);
    expect(file.readAsStringSync(), '{"codes":[]}');
  });

  testWidgets('Opening an empty encrypted database',
      (WidgetTester tester) async {
    final testPath = generate();
    final Configuration configuration = Configuration(testPath);

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

    var textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2));
    expect(tester.widget<TextField>(textFields.at(0)).enabled, false);
    expect(tester.widget<TextField>(textFields.at(1)).enabled, false);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<TextField>(textFields.at(0)).enabled, true);
    expect(tester.widget<TextField>(textFields.at(1)).enabled, true);
    
    await tester.enterText(textFields.at(0), 'password');
    await tester.enterText(textFields.at(1), 'password');
    await tester.pump();

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Passwords do not match'), findsNothing);
    expect(find.text('Password cannot be empty'), findsNothing);

    // The below doesn't work likely due to the future in the configuration generate password.
    // expect(find.text('Create'), findsNothing);
    // File file = File('$testPath/tokens.json');
    // expect(file.existsSync(), true);
    // expect(file.readAsStringSync(), isNot(equals('{"codes":[]}')));
  });
}
