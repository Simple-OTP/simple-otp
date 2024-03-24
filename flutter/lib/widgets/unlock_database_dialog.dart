import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/provider/database_secret.dart';
import 'package:simple_otp/provider/secrets_list.dart';

import '../routes/database_route.dart';

class UnlockDatabase extends SimpleDialog {
  final StorageManager storageManager;

  UnlockDatabase({super.key, StorageManager? storageManager})
      : storageManager = storageManager ?? const StorageManager();

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Add Account'),
      children: <Widget>[
        TextField(
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          controller: _passwordController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter Password',
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
              onPressed: () => handleUnlockDatabase(context),
              child: const Text('Create'),
            ),
          ],
        ),
      ],
    );
  }

  void handleUnlockDatabase(BuildContext context) {
    final password = _passwordController.text;
    // Setup the secret key
    Provider.of<DatabaseSecret>(context, listen: false)
        .setSecretFromPassword(password)
        .then((secretKey) {
      // Write the empty database
      storageManager.readDatabase(secretKey).then((value) {
        // Set the empty database into the OTP list
        Provider.of<SecretList>(context, listen: false).override = value;
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DatabaseRoute(),
            ));
      });
    });
  }
}
