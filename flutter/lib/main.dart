import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/provider/otp_secret_provider.dart';
import 'package:simple_otp/provider/secrets_list.dart';
import 'package:simple_otp/routes/lock_route.dart';

import 'manager/storage_manager.dart';

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
  final StorageManager? storageManager;

  const OTPProviders({super.key, this.storageManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => SecretList()),
      ChangeNotifierProvider(create: (context) => ActiveOTPSecret()),
    ], child: OTPApp(storageManager: storageManager));
  }
}

class OTPApp extends StatelessWidget {
  final StorageManager? storageManager;

  const OTPApp({super.key, this.storageManager});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authy Replacement',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LockRoute(
        storageManager: storageManager,
      ),
    );
  }
}
