import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:simple_otp/model/otp_sescret.dart';

class StorageManager {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print("Path: $path");
    return File('$path/tokens.json');
  }

  Future<List<OTPSecret>> readDatabase() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();
      final jsonDecoded = jsonDecode(contents) as Map<String, dynamic>;
      final parsed = jsonDecoded['codes'] as List<dynamic>;
      final list =
          parsed.map<OTPSecret>((json) => OTPSecret.fromJson(json)).toList();
      list.sort();
      return list;
    } catch (e) {
      // If encountering an error, return 0
      print("Error: $e");
      return List.empty();
    }
  }
}
