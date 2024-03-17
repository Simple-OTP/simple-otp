import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/routes/database_route.dart';

import '../provider/secrets_list.dart';

class LockRoute extends StatelessWidget {
  const LockRoute({super.key});

  void _unlockDatabase(BuildContext context) {
    StorageManager().readDatabase().then((value) =>
        Provider.of<SecretList>(context, listen: false).override = value);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DatabaseRoute(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Database Locked'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Unlock Database'),
          onPressed: () {
            _unlockDatabase(context);
          },
        ),
      ),
    );
  }
}
