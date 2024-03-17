import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_otp/model/otp_secret.dart';

class StorageManager {
  static const fileName = "tokens.json";

  var logger = Logger();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    final completePath = '$path/$fileName';
    logger.d("Storage Path: $completePath");
    return File(completePath);
  }

  Future<List<OTPSecret>> readDatabase() async {
    logger.d("Reading Database");
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        logger.d("File does not exist");
        return List.empty();
      }

      // Read the file
      final contents = await file.readAsString();
      final jsonDecoded = jsonDecode(contents) as Map<String, dynamic>;
      final parsed = jsonDecoded['codes'] as List<dynamic>;
      final list =
          parsed.map<OTPSecret>((json) => OTPSecret.fromJson(json)).toList();
      list.sort();
      logger.d("result: $list");
      return list;
    } catch (e) {
      // If encountering an error, return 0
      logger.e("Error: $e", error: e, stackTrace: StackTrace.current);
      return List.empty();
    }
  }
}
