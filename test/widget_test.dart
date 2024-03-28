// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:mockito/annotations.dart';

import 'package:simple_otp/manager/storage_manager.dart';


@GenerateMocks([StorageManager])
void main() {
  // Disabled until this settles

  // testWidgets('Opening an empty database', (WidgetTester tester) async {
  //   final storageManager = MockStorageManager();
  //   when(storageManager.doesDatabaseExist()).thenAnswer((_) => Future.value(true));
  //   when(storageManager.readDatabase()).thenAnswer((_) => Future.value([]));
  //
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(OTPProviders(storageManager: storageManager));
  //
  //   await tester.pump();// handle the builder
  //   // Verify that our counter starts at 0.
  //   expect(find.text('Unlock Database'), findsOneWidget);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   expect(find.byIcon(Icons.block), findsNothing);
  //   expect(find.byType(ElevatedButton), findsOneWidget);
  //   await tester.tap(find.byType(ElevatedButton));
  //   await tester.pump();// handle the route push
  //   expect(find.text('Unlock Database'), findsOneWidget);
  //   expect(find.byIcon(Icons.block), findsNothing);
  //   await tester.pump();// handle the new route
  //   expect(find.byIcon(Icons.block), findsOneWidget);
  // });
}
