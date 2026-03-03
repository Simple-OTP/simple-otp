import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_otp/exceptions.dart';
import 'package:simple_otp/manager/crypt_manager.dart';
import 'package:simple_otp/manager/storage_manager.dart';
import 'package:simple_otp/model/otp_secret.dart';
import 'package:simple_otp/provider/secrets_list.dart';

/// A ByteManager that works in memory; StorageManager still writes to a file.
class _MemoryManager implements ByteManager {
  @override
  Future<Uint8List> toBytes(String data) async =>
      Uint8List.fromList(data.codeUnits);

  @override
  Future<String> fromBytes(Uint8List data) async =>
      String.fromCharCodes(data);
}

/// Creates a StorageManager backed by a real file in [dir] with name [name],
/// pre-populated with an empty database so reads won't fail.
Future<StorageManager> _makeStorage(Directory dir, String name) async {
  final file = File('${dir.path}/$name');
  final sm = StorageManager(_MemoryManager(), file);
  await sm.writeDatabase([]);
  return sm;
}

void main() {
  // Use setUpAll/tearDownAll so no async writes outlive the directory.
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('secrets_list_test_');
  });

  tearDownAll(() {
    tempDir.deleteSync(recursive: true);
  });

  final secretA =
      OTPSecret(issuer: 'Acme', username: 'alice', secret: 'SECRETAAA');
  final secretB =
      OTPSecret(issuer: 'Beta', username: 'bob', secret: 'SECRETBBB');
  final secretC =
      OTPSecret(issuer: 'Acme', username: 'charlie', secret: 'SECRETCCC');

  // Counter for unique file names per test, avoiding cross-test interference.
  var counter = 0;
  Future<StorageManager> storage() => _makeStorage(tempDir, 'tokens_${counter++}.json');

  test('throws DatabaseNotInitializedException when not initialized — add', () {
    final sl = SecretList();
    expect(() => sl.add(secretA),
        throwsA(isA<DatabaseNotInitializedException>()));
  });

  test('throws DatabaseNotInitializedException when not initialized — addAll',
      () {
    final sl = SecretList();
    expect(() => sl.addAll([secretA]),
        throwsA(isA<DatabaseNotInitializedException>()));
  });

  test('throws DatabaseNotInitializedException when not initialized — remove',
      () {
    final sl = SecretList();
    expect(() => sl.remove(secretA),
        throwsA(isA<DatabaseNotInitializedException>()));
  });

  test('unlockDatabase starts with empty list for a fresh storage', () async {
    final sl = SecretList();
    await sl.unlockDatabase(await storage());
    expect(sl.otpSecrets, isEmpty);
  });

  test('add inserts a secret', () async {
    final sl = SecretList();
    await sl.unlockDatabase(await storage());
    sl.add(secretA);
    expect(sl.otpSecrets, contains(secretA));
  });

  test('add duplicate is a no-op', () async {
    final sl = SecretList();
    await sl.unlockDatabase(await storage());
    sl.add(secretA);
    sl.add(secretA);
    expect(sl.otpSecrets.length, 1);
  });

  test('addAll deduplicates', () async {
    final sl = SecretList();
    await sl.unlockDatabase(await storage());
    sl.addAll([secretA, secretA, secretB]);
    expect(sl.otpSecrets.length, 2);
  });

  test('list is sorted after add', () async {
    final sl = SecretList();
    await sl.unlockDatabase(await storage());
    sl.add(secretB);
    sl.add(secretA);
    expect(sl.otpSecrets.first, secretA); // A < B alphabetically
  });

  test('list is sorted by issuer then username', () async {
    final sl = SecretList();
    await sl.unlockDatabase(await storage());
    // secretC is Acme/charlie, secretA is Acme/alice — alice < charlie
    sl.addAll([secretC, secretA, secretB]);
    expect(sl.otpSecrets[0], secretA);
    expect(sl.otpSecrets[1], secretC);
    expect(sl.otpSecrets[2], secretB);
  });

  test('remove deletes a secret', () async {
    final sl = SecretList();
    await sl.unlockDatabase(await storage());
    sl.add(secretA);
    sl.remove(secretA);
    expect(sl.otpSecrets, isEmpty);
  });

  test('clear empties the list and locks the database', () async {
    final sl = SecretList();
    await sl.unlockDatabase(await storage());
    sl.add(secretA);
    sl.clear();
    expect(sl.otpSecrets, isEmpty);
    expect(() => sl.add(secretB),
        throwsA(isA<DatabaseNotInitializedException>()));
  });

  test('otpSecrets is unmodifiable', () async {
    final sl = SecretList();
    await sl.unlockDatabase(await storage());
    expect(() => sl.otpSecrets.add(secretA), throwsUnsupportedError);
  });

  test('persistence: written secrets can be read back', () async {
    final sm = await storage();
    final sl = SecretList();
    await sl.unlockDatabase(sm);
    sl.add(secretA);
    sl.add(secretB);

    // Flush: wait for the unawaited writeDatabase from add() to complete.
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final sl2 = SecretList();
    await sl2.unlockDatabase(sm);
    expect(sl2.otpSecrets, containsAll([secretA, secretB]));
    expect(sl2.otpSecrets.length, 2);
  });
}
