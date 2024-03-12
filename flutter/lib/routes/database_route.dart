import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:simple_otp/widgets/otp_widget.dart';

import '../model/otp_sescret.dart';

// This app view holds onto the database.
// inside is two widgets, once is the database list itself,
// and the other is the code generation view to the right for the selected
// entry.
class DatabaseRoute extends StatefulWidget {
  const DatabaseRoute({super.key});

  @override
  State<DatabaseRoute> createState() => _DatabaseRouteState();
}

class _DatabaseRouteState extends State<DatabaseRoute> {
  OTPSecret? _secret;

  void setSecret(OTPSecret secret) {
    setState(() {
      _secret = secret;
    });
  }

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Simple OTP';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: ListView(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.map),
                      title: Text('Map'),
                      onTap: () => setSecret(OTPSecret(
                          issuer: "google",
                          username: "fred@dol",
                          secret: OTP.randomSecret()))),
                  ListTile(
                      leading: Icon(Icons.photo_album),
                      title: Text('Album'),
                      onTap: () => setSecret(OTPSecret(
                          issuer: "google",
                          username: "fred@dol",
                          secret: OTP.randomSecret()))),
                  ListTile(
                      leading: Icon(Icons.phone),
                      title: Text('Phone'),
                      onTap: () => setSecret(OTPSecret(
                          issuer: "google",
                          username: "fred@dol",
                          secret: OTP.randomSecret()))),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: OTPWidget(secret: _secret),
            ),
          ],
        ),
      ),
    );
  }
}
