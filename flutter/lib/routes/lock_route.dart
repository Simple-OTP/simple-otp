import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:simple_otp/model/otp_sescret.dart';
import 'package:simple_otp/routes/database_route.dart';

import 'otp_route.dart';

class LockRoute extends StatelessWidget {
  const LockRoute({super.key});

  void _unlockDatabase(BuildContext context) {
    final OTPSecret secret = OTPSecret(issuer: "google", username: "fred@dol", secret: OTP.randomSecret());
    Navigator.push(
      context,
      //MaterialPageRoute(builder: (context) => OTPWidget(secret: secret),
      MaterialPageRoute(builder: (context) => DatabaseRoute(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Database Locked'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Unlock Database'),
          onPressed: () {_unlockDatabase(context);},
        ),
      ),
    );
  }
}