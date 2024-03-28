import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:simple_otp/manager/nonce_manager.dart';

/// The secret key used to encrypt and decrypt the database. It uses the
/// included [NonceManager] to generate the secret key.
class DatabaseSecret extends ChangeNotifier {
  final NonceManager _nonceManager;
  SecretKey? _secret;

  DatabaseSecret({NonceManager? nonceManager})
      : _nonceManager = nonceManager ?? NonceManager();

  SecretKey? get secret => _secret;

  /// OWASP approved: Argon2id "m=12288 (12 MiB), t=3, p=1" from https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
  /// on March 24, 2024
  /// Upped the iterations to 4 for a bit of future proofing. Will need to
  /// eventually store the configuration so we can upgrade later.
  Future<SecretKey> setSecretFromPassword(String password) async {
    final algorithm = Argon2id(
      parallelism: 1,
      memory: 12000, // 12 000 x 1kB block = 12 MB
      iterations: 4,
      hashLength: 32,
    );
    final nonce = await _nonceManager.readNonce();
    _secret = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: nonce,
    );
    notifyListeners();
    return _secret!;
  }

  void clear() {
    _secret = null;
    notifyListeners();
  }
}
