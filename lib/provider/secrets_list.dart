import 'dart:collection';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:simple_otp/manager/nonce_manager.dart';
import 'package:simple_otp/model/otp_secret.dart';

/// When there are no secrets, the database is locked
class SecretList extends ChangeNotifier {
  final NonceManager _nonceManager;
  SecretKey? _secret;
  List<OTPSecret> _otpSecrets = [];

  SecretList({NonceManager? nonceManager})
      : _nonceManager = nonceManager ?? NonceManager();

  UnmodifiableListView<OTPSecret> get otpSecrets =>
      UnmodifiableListView(_otpSecrets);

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
    return _secret!;
  }

  set override(List<OTPSecret> newSecrets) {
    _otpSecrets = newSecrets;
    _otpSecrets.sort();
    notifyListeners();
  }

  void addAll(List<OTPSecret> list) {
    _otpSecrets.addAll(list);
    _otpSecrets = _otpSecrets.toSet().toList(); // remove dups
    _otpSecrets.sort();
    notifyListeners();
  }

  void add(OTPSecret secret) {
    if (!_otpSecrets.contains(secret)) {
      _otpSecrets.add(secret);
      _otpSecrets.sort();
      notifyListeners();
    }
  }

  void remove(OTPSecret secret) {
    _otpSecrets.remove(secret);
    notifyListeners();
  }

  void clear() {
    _otpSecrets.clear();
    _secret = null;
    notifyListeners();
  }
}
