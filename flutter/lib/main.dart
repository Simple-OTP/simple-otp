import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/provider/otp_secret_provider.dart';
import 'package:simple_otp/provider/secrets_list.dart';
import 'package:simple_otp/routes/lock_route.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => SecretList()),
    ChangeNotifierProvider(create: (context) => ActiveOTPSecret()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
