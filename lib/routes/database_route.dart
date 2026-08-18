import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/model/otp_secret.dart';
import 'package:simple_otp/provider/active_otp_secret_provider.dart';
import 'package:simple_otp/provider/secrets_list.dart';
import 'package:simple_otp/util/log.dart';
import 'package:simple_otp/widgets/add_account_dialog.dart';
import 'package:simple_otp/widgets/error_dialog.dart';
import 'package:simple_otp/widgets/otp_selection_item.dart';
import 'package:simple_otp/widgets/otp_widget.dart';

// This app view holds onto the database.
// inside is two widgets, once is the database list itself,
// and the other is the code generation view to the right for the selected
// entry.
class DatabaseRoute extends StatelessWidget {
  const DatabaseRoute({
    super.key,
  });

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
                  onPressed: () => showDialog<void>(
                      context: context,
                      barrierDismissible: true, // user must tap button!
                      builder: (BuildContext context) {
                        return AddAccount();
                      })),
              const Spacer(),
              PopupMenuButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry>[
                      PopupMenuItem(
                        value: 'import',
                        onTap: () => doImport(
                            Provider.of<SecretList>(context, listen: false),
                            (e) => showDialog<void>(
                                context: context,
                                barrierDismissible: true,
                                // user must tap button!
                                builder: (BuildContext context) {
                                  return ErrorDialog(message: 'Error: $e');
                                })),
                        child: const Text('Import'),
                      ),
                      PopupMenuItem(
                        value: 'export',
                        onTap: () => doExport(
                            Provider.of<SecretList>(context, listen: false)),
                        child: const Text('Export'),
                      ),
                    ];
                  }),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.lock),
                tooltip: 'Lock Database',
                onPressed: () {
                  Provider.of<SecretList>(context, listen: false).clear();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: Consumer<ActiveOTPSecret>(
            builder: (context, ActiveOTPSecret activeSecret, child) {
          if (activeSecret.otpSecret == null) {
            return DatabaseListView();
          } else {
            return const OTPWidget();
          }
        }),
      ),
    );
  }

  void doExport(final SecretList secretList) {
    final String json = OTPSecret.writeToJSON(secretList.otpSecrets);
    FilePicker.saveFile(
            fileName: 'simple_otp.json',
            allowedExtensions: ['json'],
            type: FileType.any,
            bytes: utf8.encode(json))
        .then((uri) {
      // Every platform implementation writes the bytes itself, so there is
      // nothing left to do here but report the destination.
      if (uri != null) {
        logger.d('File saved: $uri');
      } else {
        logger.d('no file selected');
      }
    });
  }

  /// consider moving this to the storage tier.
  void doImport(
      final SecretList secretList, final void Function(Object) onError) async {
    try {
      PlatformFile? result = await FilePicker.pickFile(
        allowedExtensions: ['json', 'jsn'],
      );
      if (result != null) {
        logger.d("Loading ${result.uri}");
        List<OTPSecret> secrets =
            OTPSecret.readFromJson(utf8.decode(await result.readAsBytes()));
        secretList.addAll(secrets);
      } else {
        logger.d('no file selected');
      }
    } catch (e) {
      logger.e('Error: $e', error: e, stackTrace: StackTrace.current);
      onError.call(e);
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
