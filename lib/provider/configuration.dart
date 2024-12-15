import 'dart:convert';
import 'dart:io';

import 'package:cryptography_plus/cryptography_plus.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:simple_otp/manager/nonce_manager.dart';
import 'package:simple_otp/util/log.dart';

/// The provider for the configuration element.
class Configuration extends ChangeNotifier {
  static const _configFileName = "simple_otp.json";
  static const _tokensFileName = "tokens.json";
  static final Mutex _saveMutex = Mutex();

  /// Factory method to generate a configuration object. It cannot be a
  /// Dart constructor or dart factory because it is asynchronous.
  factory Configuration(String internalDirectoryPath) {
    // Normal usage we use the defaults.
    NonceManager nonceManager = NonceManager();
    // Get the configuration to bootstrap, if it exists, else use the empty one.
    var file = _localFile(internalDirectoryPath);
    Configuration instance;
    if (file.existsSync()) {
      logger.d("Reading configuration from file");
      var jsonString = file.readAsStringSync();
      instance = Configuration._fromJson(
          nonceManager: nonceManager,
          internalDirectoryPath: internalDirectoryPath,
          json: jsonDecode(jsonString));
    } else {
      logger.d("Creating new configuration");
      instance = Configuration._empty(
          nonceManager: nonceManager,
          internalDirectoryPath: internalDirectoryPath);
      instance._saveConfiguration();
    }
    return instance;
  }

  /// How we get the file internally.
  static File _localFile(String path) {
    final completePath = '$path/$_configFileName';
    return File(completePath);
  }

  bool doesDatabaseExist() {
    final file = getDatabaseFile();
    return file.existsSync();
  }

  File getDatabaseFile() {
    final completePath = '$internalDirectoryPath/$_tokensFileName';
    logger.d("Storage Path: $completePath");
    return File(completePath);
  }

  final NonceManager _nonceManager;
  final String _nonce;
  final String internalDirectoryPath;
  bool _requirePassword = false;

  Configuration._empty(
      {required NonceManager nonceManager, required this.internalDirectoryPath})
      : _nonceManager = nonceManager,
        _requirePassword = false,
        _nonce = nonceManager.generateNonceAsString();

  Configuration._fromJson({
    required NonceManager nonceManager,
    required this.internalDirectoryPath,
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

  /// OWASP approved: Argon2id "m=12288 (12 MiB), t=3, p=1" from https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
  /// on March 24, 2024
  /// Upped the iterations to 4 for a bit of future proofing. Will need to
  /// eventually store the configuration so we can upgrade later.
  ///
  /// Moved to configuration so to future proof it when its changeable.
  Future<SecretKey> generateFromPassword(String password) async {
    final algorithm = Argon2id(
      parallelism: 1,
      memory: 12000, // 12 000 x 1kB block = 12 MB
      iterations: 4,
      hashLength: 32,
    );
    return await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: nonce(),
    );
  }

  /// Need to make sure this method isn't called twice at the same time.
  /// Mutex anyone?
  Future<void> _saveConfiguration() async {
    var file = _localFile(internalDirectoryPath);
    var string = _toJson();
    await _saveMutex.protect(() async {
      file.writeAsStringSync(string, flush: true);
    });
  }
}
