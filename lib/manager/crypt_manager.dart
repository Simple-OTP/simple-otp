import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography_plus/cryptography_plus.dart';
import 'package:simple_otp/util/log.dart';

abstract class ByteManager {
  Future<Uint8List> toBytes(String data);

  Future<String> fromBytes(Uint8List data);

  factory ByteManager.fromKey(SecretKey secretKey) {
    return CryptManager(secretKey);
  }

  factory ByteManager.plain() {
    return PlainManager();
  }
}

class CryptManager implements ByteManager {
  final SecretKey _secretKey;

  const CryptManager(this._secretKey);

  /// Encrypt the data
  @override
  Future<Uint8List> toBytes(String data) async {
    logger.d("Encrypting Database");
    final algorithm = AesGcm.with256bits();
    final secretBox = await algorithm.encryptString(
      data,
      secretKey: _secretKey,
    );
    return secretBox.concatenation();
  }

  /// Decrypt the data
  @override
  Future<String> fromBytes(Uint8List data) async {
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
}

class PlainManager implements ByteManager {
  @override
  Future<Uint8List> toBytes(String data) async {
    return Future.value(Uint8List.fromList(data.codeUnits));
  }

  @override
  Future<String> fromBytes(Uint8List data) async {
    return Future.value(String.fromCharCodes(data));
  }
}
