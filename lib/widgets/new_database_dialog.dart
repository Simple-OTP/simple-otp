import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/manager/crypt_manager.dart';
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
    return Consumer<Configuration>(
        builder: (context, Configuration config, child) {
      return SimpleDialog(
        title: const Text('Create Database'),
        children: <Widget>[
          Row(
            children: <Widget>[
              const Spacer(),
              const Text('Use a local password'),
              Checkbox(
                  value: config.requirePassword,
                  onChanged: (_) => config.toggleRequirePassword()),
              const Spacer(),
            ],
          ),
          TextField(
            enabled: config.requirePassword,
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
            enabled: config.requirePassword,
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
    });
  }

  void handleNewDatabase(BuildContext context) {
    final configuration = Provider.of<Configuration>(context, listen: false);
    if (!configuration.requirePassword) {
      final secretList = Provider.of<SecretList>(context, listen: false);
      secretList.newDatabase(
          StorageManager(ByteManager.plain(), configuration.getDatabaseFile()));
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DatabaseRoute(),
          ));
    } else if (_passwordController.text != _reenterPasswordController.text) {
      showDialog<void>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return const ErrorDialog(message: 'Passwords do not match');
          });
    } else if (_passwordController.text.isEmpty) {
      showDialog<void>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return const ErrorDialog(message: 'Password cannot be empty');
          });
    } else {
      final password = _passwordController.text;
      // Setup the secret key
      final secretList = Provider.of<SecretList>(context, listen: false);
      configuration.generateFromPassword(password).then((secretKey) {
        var byteManager = ByteManager.fromKey(secretKey);
        secretList.newDatabase(
            StorageManager(byteManager, configuration.getDatabaseFile()));
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
