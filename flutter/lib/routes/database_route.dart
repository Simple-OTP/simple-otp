import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/model/otp_secret.dart';
import 'package:simple_otp/provider/otp_secret_provider.dart';
import 'package:simple_otp/widgets/otp_widget.dart';

import '../manager/storage_manager.dart';
import '../provider/secrets_list.dart';
import '../widgets/add_account_dialog.dart';
import '../widgets/otp_selection_item.dart';

// This app view holds onto the database.
// inside is two widgets, once is the database list itself,
// and the other is the code generation view to the right for the selected
// entry.
class DatabaseRoute extends StatelessWidget {
  const DatabaseRoute({super.key});

  static final logger = Logger();

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Simple OTP';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Account',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddAccount()));
                },
              ),
              const Spacer(),
              PopupMenuButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry>[
                      PopupMenuItem(
                        value: 'import',
                        onTap: () => doImport(Provider.of<SecretList>(context, listen: false)),
                        child: const Text('Import'),
                      ),
                      PopupMenuItem(
                        value: 'export',
                        onTap: () => doNothing(),
                        child: const Text('Export'),
                      ),
                    ];
                  }),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.lock),
                tooltip: 'Lock Database',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: DatabaseListView(),
            ),
            const Expanded(
              flex: 3,
              child: OTPWidget(),
            ),
          ],
        ),
      ),
    );
  }

  void doNothing() {
    logger.d('do nothing');
  }

  /// consider moving this to the storage tier.
  void doImport(SecretList secretList) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['json', 'jsn'],
    );
    if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
      String path = result.files.single.path!;
      logger.d("Loading $path");
      File file = File(path);
      List<OTPSecret> secrets = await StorageManager().readFromJson(file.readAsStringSync());
      secretList.addAll(secrets);
    } else {
      logger.d('no file selected');
    }
  }
}

class DatabaseListView extends ListView {
  DatabaseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SecretList>(builder: (context, secretList, child) {
      var otpSecrets = secretList.otpSecrets;
      return Consumer<ActiveOTPSecret>(
          builder: (context, ActiveOTPSecret activeSecret, child) {
        return ListView.separated(
            padding: const EdgeInsets.all(20),
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemCount: otpSecrets.length,
            itemBuilder: (BuildContext context, int index) {
              return OTPSelectionItem(
                  otpSecret: otpSecrets[index],
                  selected: otpSecrets[index] == activeSecret.otpSecret);
            });
      });
    });
  }
}
