import 'package:flutter/material.dart';

import '../manager/nonce_manager.dart';
import 'error_dialog.dart';

class NewDatabase extends SimpleDialog {
  final NonceManager nonceManager;

  NewDatabase({super.key, NonceManager? nonceManager})
      : nonceManager = nonceManager ?? NonceManager();

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
              onPressed: () {
                if (_passwordController.text !=
                    _reenterPasswordController.text) {
                  showDialog<void>(
                      context: context,
                      barrierDismissible: true, // user must tap button!
                      builder: (BuildContext context) {
                        return const ErrorDialog(
                            message: 'Passwords do not match');
                      });
                } else {}
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ],
    );
  }
}
