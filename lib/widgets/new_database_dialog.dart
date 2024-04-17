import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/provider/configuration.dart';
import 'package:simple_otp/provider/secrets_list.dart';
import 'package:simple_otp/routes/database_route.dart';

import 'error_dialog.dart';

class NewDatabase extends SimpleDialog {
  NewDatabase({super.key});

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterPasswordController =
      TextEditingController();

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
        TextField(
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          controller: _reenterPasswordController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Re-enter Password',
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
              onPressed: () => handleNewDatabase(context),
              child: const Text('Create'),
            ),
          ],
        ),
      ],
    );
  }

  void handleNewDatabase(BuildContext context) {
    if (_passwordController.text != _reenterPasswordController.text) {
      showDialog<void>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return const ErrorDialog(message: 'Passwords do not match');
          });
    } else {
      final password = _passwordController.text;
      // Setup the secret key
      final secretList = Provider.of<SecretList>(context, listen: false);
      configuration.generateFromPassword(password).then((secretKey) {
        secretList.newDatabase(StorageManager(secretKey));
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DatabaseRoute(),
            ));
      });
    }
  }
}
