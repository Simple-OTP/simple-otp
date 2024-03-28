import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/model/otp_secret.dart';
import 'package:simple_otp/provider/database_secret.dart';
import 'package:simple_otp/provider/secrets_list.dart';

import '../provider/otp_secret_provider.dart';
import 'error_dialog.dart';

class DeleteOTPSecret extends SimpleDialog {
  const DeleteOTPSecret(
      {super.key, required this.otpSecret, StorageManager? storageManager})
      : storageManager = storageManager ?? const StorageManager();

  final StorageManager storageManager;
  final OTPSecret otpSecret;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Are you sure you want to delete OTP Secret?'),
      children: <Widget>[
        Text("Issuer: ${otpSecret.issuer}\nUsername: ${otpSecret.username}"),
        Row(
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => handleDelete(context),
              child: const Text('delete'),
            ),
          ],
        ),
      ],
    );
  }

  void handleDelete(BuildContext context) {
    Provider.of<SecretList>(context, listen: false).remove(otpSecret);
    final list = Provider.of<SecretList>(context, listen: false).otpSecrets;
    final secret = Provider.of<DatabaseSecret>(context, listen: false).secret!;
    Provider.of<ActiveOTPSecret>(context, listen: false).otpSecret = null;
    storageManager.writeDatabase(list, secret).then((value) {
      Navigator.pop(context);
    }).catchError((e) {
      showDialog<void>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return ErrorDialog(message: "$e");
          });
      return null;
    });
  }
}
