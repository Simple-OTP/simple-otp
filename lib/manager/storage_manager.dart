import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mutex/mutex.dart';
import 'package:simple_otp/manager/crypt_manager.dart';
import 'package:simple_otp/model/otp_secret.dart';
import 'package:simple_otp/provider/configuration.dart';
import 'package:simple_otp/util/log.dart';

class StorageManager {
  static const fileName = "tokens.json";
  static final Mutex _saveMutex = Mutex();

  final ByteManager _byteManager;

  const StorageManager(this._byteManager);

  static bool doesDatabaseExist() {
    final file = _localFile;
    return file.existsSync();
  }

  static File get _localFile {
    final path = configuration.internalDirectoryPath;
    final completePath = '$path/$fileName';
    logger.d("Storage Path: $completePath");
    return File(completePath);
  }

  Future<List<OTPSecret>> readDatabase() async {
    logger.d("Reading Database");
    final file = _localFile;
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
    logger.d("Writing Database start");
    final file = _localFile;
    final jsonString = OTPSecret.writeToJSON(secrets);
    final encrypted = await _byteManager.toBytes(jsonString);
    await _saveMutex.protect(() async {
      file.writeAsBytesSync(encrypted, flush: true);
    });
    logger.d("Writing Database end");
  }
}
