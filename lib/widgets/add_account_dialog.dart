import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/model/otp_secret.dart';

import '../provider/active_otp_secret_provider.dart';
import '../provider/secrets_list.dart';
import 'error_dialog.dart';

class AddAccount extends SimpleDialog {
  AddAccount({super.key, StorageManager? storageManager})
      : storageManager = storageManager ?? const StorageManager();

  final StorageManager storageManager;
  final TextEditingController _issuerController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Add Account'),
      children: <Widget>[
        TextField(
          controller: _issuerController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Issuer',
          ),
        ),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
          ),
        ),
        TextField(
          controller: _secretController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Secret',
          ),
        ),
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
              onPressed: () => _handleAddAccount(context),
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  void _handleAddAccount(BuildContext context) {
    try {
      _verifyFields(context);
      final OTPSecret otpSecret = OTPSecret(
          issuer: _issuerController.text,
          username: _usernameController.text,
          secret: _secretController.text);
      Provider.of<SecretList>(context, listen: false).add(otpSecret);
      Provider.of<ActiveOTPSecret>(context, listen: false).otpSecret =
          otpSecret;
      final list = Provider.of<SecretList>(context, listen: false).otpSecrets;
      final secret = Provider.of<SecretList>(context, listen: false).secret!;
      storageManager.writeDatabase(list, secret).then((value) {
        Navigator.pop(context);
      }).catchError((e) {
        showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(message: '$e');
            });
        return null;
      });
    } catch (e) {
      showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(message: '$e');
          });
    }
  }

  void _verifyFields(BuildContext context) {
    if (_issuerController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _secretController.text.isEmpty) {
      throw 'All fields are required';
    }
    // validate that this does not throw an exception.
    OTP.generateTOTPCodeString(
        _secretController.text, DateTime.now().millisecondsSinceEpoch);
  }
}
