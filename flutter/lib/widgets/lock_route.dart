import 'package:flutter/material.dart';

import 'otp_widget.dart';

class LockRoute extends StatelessWidget {
  const LockRoute({super.key});

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
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OTPWidget(title: 'Simple OTP')),
            );},
        ),
      ),
    );
  }
}