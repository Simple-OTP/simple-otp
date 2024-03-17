import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:simple_otp/model/otp_secret.dart';
import 'package:simple_otp/provider/otp_secret_provider.dart';
import 'package:simple_otp/widgets/otp_widget.dart';

import '../provider/secrets_list.dart';

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
  var logger = Logger();

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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddAccount()));
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
              child: DatabaseView(),
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
}

class DatabaseView extends ListView {
  DatabaseView({super.key});

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
              return OTPListItem(
                  otpSecret: otpSecrets[index],
                  selected: otpSecrets[index] == activeSecret.otpSecret);
            });
      });
    });
  }
}

class OTPListItem extends StatelessWidget {
  const OTPListItem(
      {super.key, required this.otpSecret, required this.selected});

  final OTPSecret otpSecret;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 60,
        child: Center(
          child: ListTile(
            tileColor:
                selected ? Theme.of(context).colorScheme.inversePrimary : null,
            leading: const Icon(Icons.arrow_forward),
            title: Text("${otpSecret.issuer}\n${otpSecret.username}"),
            onTap: () => Provider.of<ActiveOTPSecret>(context, listen: false)
                .otpSecret = otpSecret,
          ),
        ));
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
