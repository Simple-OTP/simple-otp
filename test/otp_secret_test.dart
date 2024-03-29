import 'package:flutter_test/flutter_test.dart';
import 'package:simple_otp/model/otp_secret.dart';

void main() {

  testWidgets("Test OTPSecret list to/from json", (WidgetTester tester) async {
    // Test the toString method of the Nonce class
    final List<OTPSecret> list = [
      OTPSecret(issuer: "issuer", username: "username", secret: "secret"),
      OTPSecret(issuer: "issuer2", username: "username2", secret: "secret2"),
    ];
    final jsonString = OTPSecret.writeToJSON(list);
    final newList = OTPSecret.readFromJson(jsonString);
    expect(newList, list);
  });

}