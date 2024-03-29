import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/model/otp_secret.dart';

void main() {
  testWidgets("Test database encryption/decryption",
      (WidgetTester tester) async {
    // Test the toString method of the Nonce class
    const mgr = StorageManager();
    final List<OTPSecret> list = [
      OTPSecret(issuer: "issuer", username: "username", secret: "secret"),
      OTPSecret(issuer: "issuer2", username: "username2", secret: "secret2"),
    ];
    final jsonString = OTPSecret.writeToJSON(list);
    final secretKey = await AesGcm.with256bits().newSecretKey();
    final encrypted = await mgr.encrypt(jsonString, secretKey);
    final decrypted = await mgr.decrypt(encrypted, secretKey);
    expect(jsonString, decrypted);
  });
}
