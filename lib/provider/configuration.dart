import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_otp/manager/nonce_manager.dart';
import 'package:simple_otp/util/log.dart';

/// The provider for the configuration element.
class Configuration extends ChangeNotifier {
  static const _fileName = "simple_otp.json";
  static final Mutex _saveMutex = Mutex();
  static Configuration? _instance;

  /// Factory method to generate a configuration object. It cannot be a
  /// Dart constructor or dart factory because it is asynchronous.
  static Future<Configuration> generate({NonceManager? nonceManager}) async {
    if (_instance != null) {
      logger.d("Returning existing instance");
      return _instance!;
    }
    nonceManager ??= NonceManager();
    var file = await _localFile;
    if (file.existsSync()) {
      logger.d("Reading configuration from file");
      var jsonString = file.readAsStringSync();
      _instance = Configuration._fromJson(
          nonceManager: nonceManager, json: jsonDecode(jsonString));
    } else {
      logger.d("Creating new configuration");
      _instance = Configuration._empty(nonceManager: nonceManager);
      await _instance!._saveConfiguration();
    }
    return _instance!;
  }

  static Configuration get instance {
    if (_instance == null) {
      logger.e("Configuration not generated yet.");
      throw Exception("Configuration not generated yet.");
    }
    return _instance!;
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

  set requirePassword(bool value) {
    _requirePassword = value;
    _saveConfiguration();
    notifyListeners();
  }

  void toggleRequirePassword() {
    requirePassword = !_requirePassword;
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
