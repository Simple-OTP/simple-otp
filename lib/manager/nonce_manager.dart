import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

import '../util/log.dart';

/// Manages the Nonce for the Argon2id algorithm used to convert the password
/// to a secret key.
class NonceManager {
  static const _fileName = "nonce.cfg";

  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    final completePath = '$path/$_fileName';
    logger.d("Storage Path: $completePath");
    return File(completePath);
  }

  List<int> generateNonce() {
    var random = Random.secure();
    return List<int>.generate(16, (index) => random.nextInt(16));
  }

  List<int> nonceFromString(String nonce) {
    List<int> result = [];
    for (var i = 0; i < nonce.length; i++) {
      result.add(int.parse(nonce[i], radix: 16));
    }
    return result;
  }

  String nonceToString(List<int> nonce) {
    return nonce.map((e) => e.toRadixString(16)).join();
  }

  void saveNonce(List<int> nonce) {
    _localFile.then((file) {
      final String hex = nonceToString(nonce);
      file.writeAsString(hex);
    });
  }

  Future<List<int>> generateAndSaveNonce() async {
    logger.d("Generating Nonce");
    final nonce = generateNonce();
    saveNonce(nonce);
    return nonce;
  }

  Future<List<int>> readNonce() async {
    logger.d("Reading Nonce");
    final file = await _localFile;
    if (!file.existsSync()) {
      logger.d("File does not exist");
      return generateAndSaveNonce();
    }
    // Read the file
    String contents;
    try {
      contents = await file.readAsString();
      return nonceFromString(contents);
    } catch (e) {
      // If encountering an error, return 0
      logger.e("Error: $e", error: e, stackTrace: StackTrace.current);
      throw ("Could not read nonce.");
    }
  }
}
