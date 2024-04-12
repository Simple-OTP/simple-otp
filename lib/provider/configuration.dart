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

  /// Factory method to generate a configuration object. It cannot be a
  /// Dart constructor or dart factory because it is asynchronous.
  static Future<Configuration> generate({NonceManager? nonceManager}) async {
    nonceManager ??= NonceManager();
    var file = await _localFile;
    if (file.existsSync()) {
      var jsonString = file.readAsStringSync();
      return Configuration._fromJson(
          nonceManager: nonceManager, json: jsonDecode(jsonString));
    } else {
      var configuration = Configuration._empty(nonceManager: nonceManager);
      await configuration._saveConfiguration();
      return configuration;
    }
  }

  /// How we get the file internally.
  static Future<File> get _localFile async {
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    final completePath = '$path/$_fileName';
    return File(completePath);
  }

  final NonceManager _nonceManager;
  final String _nonce;
  bool _requirePassword = false;

  Configuration._empty({required NonceManager nonceManager})
      : _nonceManager = nonceManager,
        _requirePassword = false,
        _nonce = nonceManager.generateNonceAsString();

  Configuration._fromJson({
    required NonceManager nonceManager,
    required Map<String, dynamic> json,
  })  : _nonceManager = nonceManager,
        _requirePassword = json['requirePassword'] as bool,
        _nonce = json['nonce'] as String;

  String _toJson() {
    Map<String, dynamic> map = {
      'requirePassword': _requirePassword,
      'nonce': _nonce,
    };
    return jsonEncode(map);
  }

  List<int> nonce() => _nonceManager.nonceFromString(_nonce);

  bool get requirePassword => _requirePassword;

  void setRequirePassword(bool value) {
    _requirePassword = value;
    _saveConfiguration();
    notifyListeners();
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
