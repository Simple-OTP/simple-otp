import 'package:flutter_test/flutter_test.dart';
import 'package:simple_otp/manager/nonce_manager.dart';

void main() {
  testWidgets("Test nonce conversion", (WidgetTester tester) async {
    // Test the toString method of the Nonce class
    final mgr = NonceManager();
    final List<int> nonce = mgr.generateNonce();
    final String nonceStr = mgr.nonceToString(nonce);
    final List<int> nonce2 = mgr.nonceFromString(nonceStr);
    expect(nonce2, equals(nonce), reason: "Nonce conversion failed: $nonceStr $nonce != $nonce2");
  });
}