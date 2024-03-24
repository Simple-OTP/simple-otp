import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_otp/model/otp_secret.dart';

import '../util/log.dart';

class StorageManager {
  static const fileName = "tokens.json";

  const StorageManager();

  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();

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
    final file = await _localFile;
    if (!file.existsSync()) {
      logger.d("File does not exist");
      return [];
    }
    // Read the file
    String contents;
    try {
      contents = await file.readAsString();
    } catch (e) {
      // If encountering an error, return 0
      logger.e("Error: $e", error: e, stackTrace: StackTrace.current);
      throw ("Could not read internal database.");
    }
    return readFromJson(contents);
  }

  Future<Uint8List> encrypt(String jsonString, SecretKey secretKey) async {
    logger.d("Encrypting Database");
    final algorithm = AesGcm.with256bits();
    final secretBox = await algorithm.encryptString(
      jsonString,
      secretKey: secretKey,
    );
    return secretBox.concatenation();
  }

  Future<String> decrypt(Uint8List data, SecretKey secretKey) async {
    logger.d("Decrypting Database");
    final algorithm = AesGcm.with256bits();
    final secretBox = SecretBox.fromConcatenation(data,
        nonceLength: algorithm.nonceLength,
        macLength: algorithm.macAlgorithm.macLength);
    final decrypted = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );
    return utf8.decode(decrypted);
  }

  Future<void> writeDatabase(List<OTPSecret> secrets) async {
    logger.d("Writing Database");
    final file = await _localFile;
    final jsonString = writeToJSON(secrets);
    await file.writeAsString(jsonString);
  }

  String writeToJSON(List<OTPSecret> secrets) {
    logger.d("Writing to String");
    return jsonEncode({"codes": secrets});
  }

  List<OTPSecret> readFromJson(String jsonString) {
    logger.d("Reading Database");
    try {
      final jsonDecoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final parsed = jsonDecoded['codes'] as List<dynamic>;
      final list =
          parsed.map<OTPSecret>((json) => OTPSecret.fromJson(json)).toList();
      list.sort();
      logger.d("result: $list");
      return list;
    } catch (e) {
      // If encountering an error, return 0
      logger.e("Error: $e", error: e, stackTrace: StackTrace.current);
      throw ("Could not read json");
    }
  }

  Future<bool> doesDatabaseExist() async {
    final file = await _localFile;
    return file.exists();
  }
}
