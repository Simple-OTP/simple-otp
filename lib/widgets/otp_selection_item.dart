import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/otp_secret.dart';
import '../provider/active_otp_secret_provider.dart';
import 'delete_otp_secret_dialog.dart';

class OTPSelectionItem extends StatelessWidget {
  const OTPSelectionItem(
      {super.key, required this.otpSecret, required this.selected});

  final OTPSecret otpSecret;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 60,
        child: Center(
          child: Row(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  tileColor: selected
                      ? Theme.of(context).colorScheme.inversePrimary
                      : null,
                  leading: const Icon(Icons.arrow_forward),
                  title: Text("${otpSecret.issuer}\n${otpSecret.username}"),
                  onTap: () =>
                      Provider.of<ActiveOTPSecret>(context, listen: false)
                          .otpSecret = otpSecret,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => showDialog<void>(
                    context: context,
                    barrierDismissible: true, // user must tap button!
                    builder: (BuildContext context) {
                      return DeleteOTPSecret(otpSecret: otpSecret);
                    }),
              ),
            ],
          ),
        ));
  }
}
