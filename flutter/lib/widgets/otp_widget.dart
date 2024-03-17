import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/model/otp_secret.dart';
import 'package:simple_otp/provider/otp_secret_provider.dart';

class OTPWidget extends StatefulWidget {
  const OTPWidget({super.key});

  @override
  State<OTPWidget> createState() => _OTPWidgetState();
}

class _OTPWidgetState extends State<OTPWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {});
      ();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget buildWithSecrete(BuildContext context, OTPSecret otpSecret) {
    var otp = OTP.generateTOTPCodeString(
        otpSecret.secret, DateTime.now().millisecondsSinceEpoch);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("${otpSecret.issuer}/${otpSecret.username}",
            style: Theme.of(context).textTheme.headlineMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              otp,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: otp));
                }),
          ],
        ),
        Text(
          OTP.remainingSeconds().toString(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveOTPSecret>(
        builder: (context, ActiveOTPSecret activeSecret, child) {
      return Center(
        child: activeSecret.otpSecret != null
            ? buildWithSecrete(context, activeSecret.otpSecret!)
            : const Icon(Icons.block),
      );
    });
  }
}
