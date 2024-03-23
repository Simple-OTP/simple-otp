import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/otp_secret.dart';
import '../provider/otp_secret_provider.dart';

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
          child: ListTile(
            tileColor:
                selected ? Theme.of(context).colorScheme.inversePrimary : null,
            leading: const Icon(Icons.arrow_forward),
            title: Text("${otpSecret.issuer}\n${otpSecret.username}"),
            onTap: () => Provider.of<ActiveOTPSecret>(context, listen: false)
                .otpSecret = otpSecret,
          ),
        ));
  }
}
