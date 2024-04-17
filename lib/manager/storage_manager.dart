import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:mutex/mutex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_otp/model/otp_secret.dart';

import '../util/log.dart';

class StorageManager {
  static const fileName = "tokens.json";
  static final Mutex _saveMutex = Mutex();

  final SecretKey _secretKey;

  const StorageManager(this._secretKey);

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
    final decrypted = await decrypt(contents);
    return OTPSecret.readFromJson(decrypted);
  }

  Future<Uint8List> encrypt(String jsonString) async {
    logger.d("Encrypting Database");
    final algorithm = AesGcm.with256bits();
    final secretBox = await algorithm.encryptString(
      jsonString,
      secretKey: _secretKey,
    );
    return secretBox.concatenation();
  }

  Future<String> decrypt(Uint8List data) async {
    logger.d("Decrypting Database");
    final algorithm = AesGcm.with256bits();
    SecretBox? secretBox;
    try {
      secretBox = SecretBox.fromConcatenation(data,
          nonceLength: algorithm.nonceLength,
          macLength: algorithm.macAlgorithm.macLength);
    } catch (e) {
      logger.e("Error: $e", error: e, stackTrace: StackTrace.current);
      throw ("Database file is corrupted.");
    }
    try {
      final decrypted = await algorithm.decrypt(
        secretBox,
        secretKey: _secretKey,
      );
      return utf8.decode(decrypted);
    } catch (e) {
      logger.e("Error: $e", error: e, stackTrace: StackTrace.current);
      throw ("Bad Password.");
    }
  }

  Future<void> writeDatabase(List<OTPSecret> secrets) async {
    logger.d("Writing Database");
    final file = await _localFile;
    final jsonString = OTPSecret.writeToJSON(secrets);
    final encrypted = await encrypt(jsonString);
    await _saveMutex.protect(() async {
      await file.writeAsBytes(encrypted, flush: true);
    });
  }
}
