import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/manager/crypt_manager.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/provider/configuration.dart';
import 'package:simple_otp/provider/secrets_list.dart';
import 'package:simple_otp/routes/database_route.dart';
import 'package:simple_otp/widgets/error_dialog.dart';
import 'package:simple_otp/widgets/new_database_dialog.dart';
import 'package:simple_otp/widgets/unlock_database_dialog.dart';

class LockRoute extends StatelessWidget {
  const LockRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SecretList>(builder: (context, secretList, child) {
      final configuration = Provider.of<Configuration>(context, listen: false);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Database Locked'),
        ),
        body: Center(
            child: configuration.doesDatabaseExist()
                ? _unlockDatabaseWidget(context)
                : _newDatabaseWidget(context)),
      );
    });
  }

  Widget _newDatabaseWidget(BuildContext context) {
    return ElevatedButton(
      child: const Text('New Database'),
      onPressed: () => showDialog<void>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return NewDatabase();
          }),
    );
  }

  Widget _unlockDatabaseWidget(BuildContext context) {
    final configuration = Provider.of<Configuration>(context, listen: false);
    return ElevatedButton(
      child: const Text('Unlock Database'),
      onPressed: () => configuration.requirePassword
          ? _handleUnlockEncryptedDatabase(context)
          : _handleUnlockedPlainDatabase(context),
    );
  }

  void _handleUnlockedPlainDatabase(BuildContext context) {
    final secretList = Provider.of<SecretList>(context, listen: false);
    final configuration = Provider.of<Configuration>(context, listen: false);
    // Setup the secret key
    try {
      var byteManager = ByteManager.plain();
      secretList
          .unlockDatabase(
              StorageManager(byteManager, configuration.getDatabaseFile()))
          .then((_) {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DatabaseRoute(),
            ));
      }).catchError((e) {
        showDialog<void>(
            context: context,
            barrierDismissible: true, // user must tap button!
            builder: (BuildContext context) {
              return ErrorDialog(message: "$e");
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

  void _handleUnlockEncryptedDatabase(BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return UnlockDatabase();
        });
  }
}
