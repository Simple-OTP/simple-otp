import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/model/otp_secret.dart';

/// When there are no secrets, the database is locked
class SecretList extends ChangeNotifier {
  StorageManager? _storageManager;
  List<OTPSecret> _otpSecrets = [];

  SecretList();

  UnmodifiableListView<OTPSecret> get otpSecrets =>
      UnmodifiableListView(_otpSecrets);

  void newDatabase(StorageManager storageManager) async {
    _storageManager = storageManager;
    _otpSecrets = [];
    _storageManager!.writeDatabase(_otpSecrets);
    notifyListeners();
  }

  Future<void> unlockDatabase(StorageManager storageManager) async {
    _storageManager = storageManager;
    final secrets = await _storageManager!.readDatabase();
    _otpSecrets = secrets;
    notifyListeners();
  }

  void addAll(List<OTPSecret> list) {
    if (_storageManager == null) throw ("Database not initialized");
    _otpSecrets.addAll(list);
    _otpSecrets = _otpSecrets.toSet().toList(); // remove dups
    _otpSecrets.sort();
    _storageManager!.writeDatabase(_otpSecrets);
    notifyListeners();
  }

  void add(OTPSecret secret) {
    if (_storageManager == null) throw ("Database not initialized");
    if (!_otpSecrets.contains(secret)) {
      _otpSecrets.add(secret);
      _otpSecrets.sort();
      _storageManager!.writeDatabase(_otpSecrets);
      notifyListeners();
    }
  }

  void remove(OTPSecret secret) {
    if (_storageManager == null) throw ("Database not initialized");
    _otpSecrets.remove(secret);
    _storageManager!.writeDatabase(_otpSecrets);
    notifyListeners();
  }

  void clear() {
    _otpSecrets.clear();
    _storageManager = null;
    notifyListeners();
  }
}
