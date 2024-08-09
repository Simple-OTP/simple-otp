import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/manager/crypt_manager.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/provider/configuration.dart';
import 'package:simple_otp/provider/secrets_list.dart';
import 'package:simple_otp/routes/database_route.dart';

import 'error_dialog.dart';

class UnlockDatabase extends SimpleDialog {
  UnlockDatabase({super.key});

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Enter in current password'),
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
              child: const Text('Unlock'),
            ),
          ],
        ),
      ],
    );
  }

  void handleUnlockDatabase(BuildContext context) {
    final password = _passwordController.text;
    final secretList = Provider.of<SecretList>(context, listen: false);
    final configuration = Provider.of<Configuration>(context, listen: false);
    // Setup the secret key
    try {
      configuration.generateFromPassword(password).then((secretKey) {
        var byteManager = ByteManager.fromKey(secretKey);
        secretList
            .unlockDatabase(
                StorageManager(byteManager, configuration.getDatabaseFile()))
            .then((_) {
          if (!context.mounted) return; // TODO REMOVE HACK
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DatabaseRoute(),
              ));
        }).catchError((e) {
          if (!context.mounted) return; // TODO REMOVE HACK
          showDialog<void>(
              context: context,
              barrierDismissible: true, // user must tap button!
              builder: (BuildContext context) {
                return ErrorDialog(message: "$e");
              });
        });
      });
    } catch (e) {
      showDialog<void>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return ErrorDialog(message: "$e");
          });
    }
  }
}
