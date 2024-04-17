import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/provider/secrets_list.dart';
import 'package:simple_otp/widgets/new_database_dialog.dart';
import 'package:simple_otp/widgets/unlock_database_dialog.dart';

class LockRoute extends StatelessWidget {
  const LockRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SecretList>(builder: (context, secretList, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Database Locked'),
        ),
        body: Center(
          child: FutureBuilder<bool>(
              future: StorageManager.doesDatabaseExist(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.data!
                      ? _unlockDatabaseWidget(context)
                      : _newDatabaseWidget(context);
                } else {
                  return const CircularProgressIndicator();
                }
              }),
        ),
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
    return ElevatedButton(
      child: const Text('Unlock Database'),
      onPressed: () => showDialog<void>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return UnlockDatabase();
          }),
    );
  }
}
