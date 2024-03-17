import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/widgets/otp_widget.dart';

import '../model/otp_secret.dart';

// This app view holds onto the database.
// inside is two widgets, once is the database list itself,
// and the other is the code generation view to the right for the selected
// entry.
class DatabaseRoute extends StatefulWidget {
  const DatabaseRoute({super.key});

  @override
  State<DatabaseRoute> createState() => _DatabaseRouteState();
}

class _DatabaseRouteState extends State<DatabaseRoute> {
  List<OTPSecret> _secrets = <OTPSecret>[];
  OTPSecret? _secret;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    StorageManager().readDatabase().then((value) => _loadSecrets(value));
  }

  void _loadSecrets(List<OTPSecret> value) {
    logger.d("Loading secrets");
    setState(() {
      _secrets = value;
    });
  }

  void setSecret(OTPSecret secret) {
    setState(() {
      _secret = secret;
    });
  }

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
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAccount()));
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.lock),
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
                child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemCount: _secrets.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                          height: 60,
                          child: Center(
                            child: ListTile(
                              tileColor: _secrets[index] == _secret
                                  ? Theme.of(context).colorScheme.inversePrimary
                                  : null,
                              leading: const Icon(Icons.arrow_forward),
                              title: Text(
                                  "${_secrets[index].issuer}\n${_secrets[index].username}"),
                              onTap: () => setSecret(_secrets[index]),
                            ),
                          ));
                    })),
            Expanded(
              flex: 3,
              child: _secret != null
                  ? OTPWidget(secret: _secret!)
                  : const Icon(Icons.block),
            ),
          ],
        ),
      ),
    );
  }
}

class AddAccount extends SimpleDialog {
  const AddAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Add Account'),
      children: <Widget>[
        const TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Issuer',
          ),
        ),
        const TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
          ),
        ),
        const TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Secret',
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
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),

      ],
    );
  }
}