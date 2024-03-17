import 'package:flutter/material.dart';
import 'package:simple_otp/model/otp_secret.dart';

class OTPSecretProvider extends ChangeNotifier {
  OTPSecret? _secret;

  OTPSecret? get otpSecret => _secret;

  set name(OTPSecret? newSecret) {
    _secret = newSecret;
    notifyListeners();
  }
}
