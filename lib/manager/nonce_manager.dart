import 'dart:math';

import 'package:simple_otp/util/log.dart';

/// Manages the Nonce for the Argon2id algorithm used to convert the password
/// to a secret key.
class NonceManager {
  String generateNonceAsString() {
    final nonce = generateNonce();
    return nonceToString(nonce);
  }

  List<int> generateNonce() {
    logger.d("Generating nonce");
    var random = Random.secure();
    return List<int>.generate(16, (index) => random.nextInt(16));
  }

  List<int> nonceFromString(String nonce) {
    List<int> result = [];
    for (var i = 0; i < nonce.length; i++) {
      result.add(int.parse(nonce[i], radix: 16));
    }
    return result;
  }

  String nonceToString(List<int> nonce) {
    return nonce.map((e) => e.toRadixString(16)).join();
  }
}
