import 'package:flutter/material.dart';
import 'package:simple_otp/model/otp_secret.dart';

class ActiveOTPSecret extends ChangeNotifier {
  OTPSecret? _secret;

  OTPSecret? get otpSecret => _secret;

  set otpSecret(OTPSecret? newSecret) {
    _secret = newSecret;
    notifyListeners();
  }
}
