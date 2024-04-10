import 'dart:core';

import 'package:simple_otp/manager/nonce_manager.dart';

/// This is our application configuration. Nonce should not change once set.
class Configuration {
  bool requirePassword;
  final String _nonce;

  Configuration({this.requirePassword = true})
      : _nonce = NonceManager().generateNonceAsString();

  Configuration.fromJson(Map<String, dynamic> json)
      : requirePassword = json['requirePassword'] as bool,
        _nonce = json['nonce'] as String;

  Map<String, dynamic> toJson() => {
        'requirePassword': requirePassword,
        'nonce': _nonce,
      };

  List<int> nonce() => NonceManager().nonceFromString(_nonce);

  @override
  String toString() {
    return 'Configuration{requirePassword: $requirePassword}';
  }
}
