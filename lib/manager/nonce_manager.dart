import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

import '../util/log.dart';

/// Manages the Nonce for the Argon2id algorithm used to convert the password
/// to a secret key.
class NonceManager {

  String generateNonceAsString() {
    final nonce = generateNonce();
    return nonceToString(nonce);
  }

  List<int> generateNonce() {
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
