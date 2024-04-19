import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_otp/manager/crypt_manager.dart';
import 'package:simple_otp/model/otp_secret.dart';

void main() {
  runAssertion(ByteManager mgr) async {
    const String jsonString =
        '[{"issuer":"issuer","username":"username","secret":"secret"}]';
    final bytes = await mgr.toBytes(jsonString);
    final result = await mgr.fromBytes(bytes);

    expect(jsonString, result);
  }

  testWidgets("Test encryption/decryption in crypt manager",
      (WidgetTester tester) async {
    SecretKey secretKey = await AesGcm.with256bits().newSecretKey();
    final ByteManager mgr = CryptManager(secretKey);
    runAssertion(mgr);
  });

  testWidgets("Test encryption/decryption in crypt manager",
      (WidgetTester tester) async {
    final ByteManager mgr = PlainManager();
    runAssertion(mgr);
  });

  testWidgets("Test database encryption/decryption",
      (WidgetTester tester) async {
    // Test the toString method of the Nonce class
    SecretKey secretKey = await AesGcm.with256bits().newSecretKey();
    final ByteManager mgr = CryptManager(secretKey);
    final List<OTPSecret> list = [
      OTPSecret(issuer: "issuer", username: "username", secret: "secret"),
      OTPSecret(issuer: "issuer2", username: "username2", secret: "secret2"),
    ];
    final jsonString = OTPSecret.writeToJSON(list);
    final encrypted = await mgr.toBytes(jsonString);
    final decrypted = await mgr.fromBytes(encrypted);
    expect(jsonString, decrypted);
  });
}
