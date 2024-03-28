import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/model/otp_secret.dart';
import 'package:simple_otp/provider/active_otp_secret_provider.dart';

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
    _timer = Timer.periodic(const Duration(milliseconds: 500), (Timer timer) {
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
        Center(
            child: CustomPaint(
          size: const Size(300, 50),
          painter: LinePainter(OTP.remainingSeconds()),
        )),
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

class LinePainter extends CustomPainter {
  LinePainter(this.remainingSeconds)
      : super(repaint: ValueNotifier<int>(remainingSeconds));

  final int remainingSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    var green = Paint()
      ..color = Colors.green
      ..strokeWidth = 15;

    var greenWidth = size.width * remainingSeconds / 30;
    var greenDiff = (size.width - greenWidth) / 2;

    Offset greenStart = Offset(greenDiff, size.height);
    Offset greenEnd = Offset(size.width - greenDiff, size.height);
    canvas.drawLine(greenStart, greenEnd, green);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
