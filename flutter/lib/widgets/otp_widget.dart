import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:simple_otp/model/otp_sescret.dart';

class OTPWidget extends StatefulWidget {
  const OTPWidget({super.key, required this.secret});

  final OTPSecret? secret;

  @override
  State<OTPWidget> createState() => _OTPWidgetState();
}

class _OTPWidgetState extends State<OTPWidget> {
  OTPSecret? get _secret => widget.secret;
  Timer? _timer;
  String _otp = "";
  String _seconds = "";

  @override
  void initState() {
    super.initState();
    _generateCode();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _generateCode();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateCode() {
    setState(() {
      if (_secret == null) {
        return;
      }
      _otp = OTP.generateTOTPCodeString(
          _secret!.secret,
          DateTime.now().millisecondsSinceEpoch);
      _seconds = OTP.remainingSeconds().toString();
    });
  }

  void _lock() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'OTP Code:',
              ),
              Text(
                _otp,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                _seconds,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        );
  }
}
