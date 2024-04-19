import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/manager/directory_manager.dart';
import 'package:simple_otp/provider/active_otp_secret_provider.dart';
import 'package:simple_otp/provider/configuration.dart';
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
  Configuration.generate().then((configuration) {
    runApp(OTPProviders(configuration: configuration));
  });
}

class OTPProviders extends StatelessWidget {
  final Configuration configuration;
  final DirectoryManager _directoryManager;

  OTPProviders(
      {super.key,
      required this.configuration,
      DirectoryManager? directoryManager})
      : _directoryManager = directoryManager ?? DirectoryManager.standard();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => configuration),
      ChangeNotifierProvider(create: (context) => SecretList()),
      ChangeNotifierProvider(create: (context) => ActiveOTPSecret()),
    ], child: OTPApp(directoryManager: _directoryManager));
  }
}

class OTPApp extends StatelessWidget {
  final DirectoryManager directoryManager;

  const OTPApp({super.key, required this.directoryManager});

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
