import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'package:simple_otp/model/otp_secret.dart';

class OTPWidget extends StatefulWidget {
  const OTPWidget({super.key, required this.secret});

  final OTPSecret secret;

  @override
  State<OTPWidget> createState() => _OTPWidgetState();
}

class _OTPWidgetState extends State<OTPWidget> {
  OTPSecret get _secret => widget.secret;
  Timer? _timer;
  String _otp = "";
  String _seconds = "";
  String _provider = "";

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
      _provider = "${_secret.issuer}/${_secret.username}";
      _otp = OTP.generateTOTPCodeString(
          _secret.secret, DateTime.now().millisecondsSinceEpoch);
      _seconds = OTP.remainingSeconds().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(_provider, style: Theme.of(context).textTheme.headlineMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _otp,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _otp));
                  }),
            ],
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
