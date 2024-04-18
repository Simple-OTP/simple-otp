import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mutex/mutex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_otp/manager/crypt_manager.dart';
import 'package:simple_otp/model/otp_secret.dart';
import 'package:simple_otp/util/log.dart';

class StorageManager {
  static const fileName = "tokens.json";
  static final Mutex _saveMutex = Mutex();

  final ByteManager _byteManager;

  const StorageManager(this._byteManager);

  static Future<bool> doesDatabaseExist() async {
    final file = await _localFile;
    return file.exists();
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();

    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    final completePath = '$path/$fileName';
    logger.d("Storage Path: $completePath");
    return File(completePath);
  }

  Future<List<OTPSecret>> readDatabase() async {
    logger.d("Reading Database");
    final file = await _localFile;
    if (!file.existsSync()) {
      logger.d("File does not exist");
      return [];
    }
    // Read the file
    Uint8List contents;
    try {
      contents = await file.readAsBytes();
    } catch (e) {
      logger.e("Error: $e", error: e, stackTrace: StackTrace.current);
      throw ("Could not read internal database.");
    }
    final decrypted = await _byteManager.fromBytes(contents);
    return OTPSecret.readFromJson(decrypted);
  }

  Future<void> writeDatabase(List<OTPSecret> secrets) async {
    logger.d("Writing Database");
    final file = await _localFile;
    final jsonString = OTPSecret.writeToJSON(secrets);
    final encrypted = await _byteManager.toBytes(jsonString);
    await _saveMutex.protect(() async {
      await file.writeAsBytes(encrypted, flush: true);
    });
  }
}
