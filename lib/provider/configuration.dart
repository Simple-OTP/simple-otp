import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_otp/manager/nonce_manager.dart';

/// The provider for the configuration element.
class Configuration extends ChangeNotifier {
  static const _fileName = "simple_otp.json";
  static final Mutex _saveMutex = Mutex();

  static Future<Configuration> generate() async {
    var config = Configuration();
    await config._loadConfiguration();
    return config;
  }

  bool _requirePassword = false;
  String? _nonce;

  List<int> nonce() => NonceManager().nonceFromString(_nonce!);

  bool get requirePassword => _requirePassword;

  void setRequirePassword(bool value) {
    _requirePassword = value;
    _saveConfiguration();
    notifyListeners();
  }

  void _fromJson(String jsonString) {
    var json = jsonDecode(jsonString) as Map<String, dynamic>;
    _requirePassword = json['requirePassword'] as bool;
    _nonce = json['nonce'] as String;
  }

  String _toJson() {
    Map<String, dynamic> map = {
      'requirePassword': _requirePassword,
      'nonce': _nonce,
    };
    return jsonEncode(map);
  }

  /// How we get the file internally.
  Future<File> get _localFile async {
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    final completePath = '$path/$_fileName';
    return File(completePath);
  }

  /// Loads the configuration if its not already loaded.
  Future<void> _loadConfiguration() async {
    var file = await _localFile;
    if (file.existsSync()) {
      var jsonString = file.readAsStringSync();
      _fromJson(jsonString);
    } else {
      _nonce = NonceManager().generateNonceAsString();
      await _saveConfiguration();
    }
  }

  /// Need to make sure this method isn't called twice at the same time.
  /// Mutex anyone?
  Future<void> _saveConfiguration() async {
    var file = await _localFile;
    var string = _toJson();
    await _saveMutex.protect(() async {
      file.writeAsStringSync(string, flush: true);
    });
  }
}
