import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/provider/otp_secret_provider.dart';
import 'package:simple_otp/provider/secrets_list.dart';
import 'package:simple_otp/routes/lock_route.dart';

void main() {
  // Error Handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FlutterError.presentError(FlutterErrorDetails(
      exception: error,
      stack: stack,
    ));
    return true;
  };
  runApp(const OTPProviders());
}

class OTPProviders extends StatelessWidget {
  const OTPProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => SecretList()),
      ChangeNotifierProvider(create: (context) => ActiveOTPSecret()),
    ], child: const OTPApp());
  }
}

class OTPApp extends StatelessWidget {
  const OTPApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authy Replacement',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LockRoute(),
    );
  }
}
