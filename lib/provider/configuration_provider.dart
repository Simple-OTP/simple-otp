import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_otp/model/configuration.dart';

/// The provider for the configuration element.
class ConfigurationProvider extends ChangeNotifier {
  static const _fileName = "simple_otp.json";
  static final Mutex _saveMutex = Mutex();

  /// The configuration object, which may not be loaded.
  Configuration? _configuration;

  /// How we get the file internally.
  Future<File> get _localFile async {
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    final completePath = '$path/$_fileName';
    return File(completePath);
  }

  /// Returns the current configuration object. If null, it will load it.
  Future<Configuration> get configuration async {
    if (_configuration == null) {
      await _loadConfiguration();
      notifyListeners();
    }
    return _configuration!;
  }

  Configuration? get configurationOrNull => _configuration;

  /// Loads the configuration if its not already loaded.
  Future<void> _loadConfiguration() async {
    if (_configuration != null) {
      return;
    }
    var file = await _localFile;
    if (file.existsSync()) {
      var jsonString = file.readAsStringSync();
      var json = jsonDecode(jsonString) as Map<String, dynamic>;
      _configuration = Configuration.fromJson(json);
    } else {
      var configuration = Configuration();
      await _saveConfiguration(configuration);
      _configuration = configuration;
    }
  }

  /// Need to make sure this method isn't called twice at the same time.
  /// Mutex anyone?
  Future<void> _saveConfiguration(Configuration configuration) async {
    var file = await _localFile;
    var string = jsonEncode(configuration.toJson());
    await _saveMutex.protect(() async {
      file.writeAsStringSync(string, flush: true);
    });
  }
}
