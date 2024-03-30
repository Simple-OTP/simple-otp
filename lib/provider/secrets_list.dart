import 'dart:collection';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:simple_otp/manager/nonce_manager.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/model/otp_secret.dart';

/// When there are no secrets, the database is locked
class SecretList extends ChangeNotifier {
  final NonceManager _nonceManager;
  final StorageManager _storageManager;
  SecretKey? _secret;
  List<OTPSecret> _otpSecrets = [];

  SecretList({NonceManager? nonceManager, StorageManager? storageManager})
      : _nonceManager = nonceManager ?? NonceManager(),
        _storageManager = storageManager ?? const StorageManager();

  UnmodifiableListView<OTPSecret> get otpSecrets =>
      UnmodifiableListView(_otpSecrets);

  SecretKey? get secret => _secret;

  /// OWASP approved: Argon2id "m=12288 (12 MiB), t=3, p=1" from https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
  /// on March 24, 2024
  /// Upped the iterations to 4 for a bit of future proofing. Will need to
  /// eventually store the configuration so we can upgrade later.
  Future<SecretKey> _setSecretFromPassword(String password) async {
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

  void newDatabase(String password) async {
    _secret = await _setSecretFromPassword(password);
    _otpSecrets = [];
    _storageManager.writeDatabase(_otpSecrets, _secret!);
    notifyListeners();
  }

  Future<void> unlockDatabase(String password) async {
    final SecretKey attemptedKey = await _setSecretFromPassword(password);
    final secrets = await _storageManager.readDatabase(attemptedKey);
    _otpSecrets = secrets;
    _secret = attemptedKey;
    notifyListeners();
  }

  void addAll(List<OTPSecret> list) {
    _otpSecrets.addAll(list);
    _otpSecrets = _otpSecrets.toSet().toList(); // remove dups
    _otpSecrets.sort();
    _storageManager.writeDatabase(_otpSecrets, _secret!);
    notifyListeners();
  }

  void add(OTPSecret secret) {
    if (!_otpSecrets.contains(secret)) {
      _otpSecrets.add(secret);
      _otpSecrets.sort();
      _storageManager.writeDatabase(_otpSecrets, _secret!);
      notifyListeners();
    }
  }

  void remove(OTPSecret secret) {
    _otpSecrets.remove(secret);
    _storageManager.writeDatabase(_otpSecrets, _secret!);
    notifyListeners();
  }

  void clear() {
    _otpSecrets.clear();
    _secret = null;
    notifyListeners();
  }
}
