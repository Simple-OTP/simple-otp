import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:simple_otp/model/otp_secret.dart';

class OTPRoute extends StatefulWidget {
  const OTPRoute({super.key, required this.secret});

  final OTPSecret secret;

  @override
  State<OTPRoute> createState() => _OTPRouteState();
}

class _OTPRouteState extends State<OTPRoute> {
  OTPSecret get _secret => widget.secret;
  Timer? _timer;
  String _otp = "";
  int _seconds = 0;

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
      _otp = OTP.generateTOTPCodeString(
          _secret.secret, DateTime.now().millisecondsSinceEpoch);
      _seconds = OTP.remainingSeconds();
    });
  }

  void _lock() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
            "OTP for ${widget.secret.issuer} / ${widget.secret.username}        "),
      ),
      body: Center(
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
              '$_seconds',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.background,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.lock),
              onPressed: _lock,
              tooltip: "Lock",
            ),
            IconButton(
              onPressed: _generateCode,
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
            )
          ],
        ),
      ),
    );
  }
}
