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
  final List<OTPSecret> _secrets = <OTPSecret>[
    OTPSecret(
        issuer: "google", username: "fred@dol", secret: OTP.randomSecret()),
    OTPSecret(
        issuer: "yahoo", username: "fred@dol", secret: OTP.randomSecret()),
    OTPSecret(
        issuer: "gargole", username: "fred@dol", secret: OTP.randomSecret()),
  ];
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
                child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                    itemCount: _secrets.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                          height: 60,
                          child: Center(
                            child: ListTile(
                              tileColor: _secrets[index] == _secret
                                  ? Theme.of(context).colorScheme.inversePrimary
                                  : null,
                              leading: const Icon(Icons.arrow_forward),
                              title: Text("${_secrets[index].issuer}\n${_secrets[index].username}"),
                              onTap: () => setSecret(_secrets[index]),
                            ),
                          ));
                    })),
            Expanded(
              flex: 3,
              child: _secret != null ? OTPWidget(secret: _secret!) : const Icon(Icons.block),
            ),
          ],
        ),
      ),
    );
  }
}
