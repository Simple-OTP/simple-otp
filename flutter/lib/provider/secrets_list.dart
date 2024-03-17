import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:simple_otp/model/otp_secret.dart';

/// When there are no secrets, the database is locked
class SecretList extends ChangeNotifier {
  List<OTPSecret> _secrets = [];

  UnmodifiableListView<OTPSecret> get otpSecrets =>
      UnmodifiableListView(_secrets);

  set override(List<OTPSecret> newSecrets) {
    _secrets = newSecrets;
    notifyListeners();
  }

  void add(OTPSecret secret) {
    _secrets.add(secret);
    notifyListeners();
  }

  void remove(OTPSecret secret) {
    _secrets.remove(secret);
    notifyListeners();
  }

  void clear() {
    _secrets.clear();
    notifyListeners();
  }
}
