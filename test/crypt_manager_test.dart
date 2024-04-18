import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_otp/manager/crypt_manager.dart';

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
}
