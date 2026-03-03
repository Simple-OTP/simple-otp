import 'dart:io';

import 'package:cryptography_plus/cryptography_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_otp/exceptions.dart';
import 'package:simple_otp/manager/crypt_manager.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/model/otp_secret.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('storage_manager_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  File file([String name = StorageManager.fileName]) =>
      File('${tempDir.path}/$name');

  final secrets = [
    OTPSecret(issuer: 'Acme', username: 'alice', secret: 'AAAA'),
    OTPSecret(issuer: 'Beta', username: 'bob', secret: 'BBBB'),
  ];

  group('PlainManager', () {
    test('readDatabase returns empty list when file does not exist', () async {
      final sm = StorageManager(ByteManager.plain(), file());
      expect(await sm.readDatabase(), isEmpty);
    });

    test('writeDatabase then readDatabase round-trips secrets', () async {
      final sm = StorageManager(ByteManager.plain(), file());
      await sm.writeDatabase(secrets);
      final result = await sm.readDatabase();
      expect(result, containsAll(secrets));
      expect(result.length, secrets.length);
    });

    test('writeDatabase creates the file', () async {
      final sm = StorageManager(ByteManager.plain(), file());
      await sm.writeDatabase(secrets);
      expect(file().existsSync(), isTrue);
    });

    test('writeDatabase with empty list produces readable empty result',
        () async {
      final sm = StorageManager(ByteManager.plain(), file());
      await sm.writeDatabase([]);
      final result = await sm.readDatabase();
      expect(result, isEmpty);
    });
  });

  group('CryptManager', () {
    late ByteManager encMgr;

    setUp(() async {
      final key = await AesGcm.with256bits().newSecretKey();
      encMgr = ByteManager.fromKey(key);
    });

    test('writeDatabase then readDatabase round-trips secrets', () async {
      final sm = StorageManager(encMgr, file());
      await sm.writeDatabase(secrets);
      final result = await sm.readDatabase();
      expect(result, containsAll(secrets));
      expect(result.length, secrets.length);
    });

    test('reading with wrong key throws BadPasswordException', () async {
      final sm = StorageManager(encMgr, file());
      await sm.writeDatabase(secrets);

      // Different key — decryption MAC check will fail
      final wrongKey = await AesGcm.with256bits().newSecretKey();
      final smWrong =
          StorageManager(ByteManager.fromKey(wrongKey), file());
      expect(
        () async => await smWrong.readDatabase(),
        throwsA(isA<BadPasswordException>()),
      );
    });

    test('reading a corrupted file throws DatabaseCorruptedException',
        () async {
      // Write garbage that cannot be parsed as a SecretBox
      file().writeAsBytesSync([1, 2, 3]);
      final sm = StorageManager(encMgr, file());
      expect(
        () async => await sm.readDatabase(),
        throwsA(isA<DatabaseCorruptedException>()),
      );
    });
  });

}
