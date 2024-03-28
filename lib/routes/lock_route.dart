import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/provider/database_secret.dart';
import 'package:simple_otp/widgets/new_database_dialog.dart';
import 'package:simple_otp/widgets/unlock_database_dialog.dart';

class LockRoute extends StatelessWidget {
  final StorageManager storageManager;

  const LockRoute({super.key, StorageManager? storageManager})
      : storageManager = storageManager ?? const StorageManager();

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseSecret>(builder: (context, databaseSecret, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Database Locked'),
        ),
        body: Center(
          child: FutureBuilder<bool>(
              future: storageManager.doesDatabaseExist(),
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
