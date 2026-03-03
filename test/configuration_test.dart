import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_otp/provider/configuration.dart';

void main() {
  late Directory tempDir;
  late String testPath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('configuration_test_');
    testPath = tempDir.path;
  });

  tearDown(() async {
    // Wait briefly for any in-flight config writes to complete before deleting.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    tempDir.deleteSync(recursive: true);
  });

  File configFile() => File('$testPath/simple_otp.json');

  test('new configuration has requirePassword=false', () {
    final config = Configuration(testPath);
    expect(config.requirePassword, isFalse);
  });

  test('new configuration writes config file to disk', () async {
    Configuration(testPath);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(configFile().existsSync(), isTrue);
  });

  test('new configuration file contains requirePassword and nonce', () async {
    Configuration(testPath);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final json =
        jsonDecode(configFile().readAsStringSync()) as Map<String, dynamic>;
    expect(json.containsKey('requirePassword'), isTrue);
    expect(json.containsKey('nonce'), isTrue);
    expect(json['requirePassword'], isFalse);
  });

  test('loading existing configuration preserves requirePassword=true',
      () async {
    final config1 = Configuration(testPath);
    config1.requirePassword = true;
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final config2 = Configuration(testPath);
    expect(config2.requirePassword, isTrue);
  });

  test('loading existing configuration preserves nonce', () async {
    final config1 = Configuration(testPath);
    final nonce1 = config1.nonce();
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final config2 = Configuration(testPath);
    expect(config2.nonce(), equals(nonce1));
  });

  test('getDatabaseFile returns path inside the internal directory', () {
    final config = Configuration(testPath);
    expect(config.getDatabaseFile().path, contains(testPath));
    expect(config.getDatabaseFile().path, endsWith('tokens.json'));
  });

  test('doesDatabaseExist returns false when tokens.json is absent', () {
    final config = Configuration(testPath);
    expect(config.doesDatabaseExist(), isFalse);
  });

  test('doesDatabaseExist returns true after tokens.json is created', () {
    final config = Configuration(testPath);
    config.getDatabaseFile().writeAsStringSync('{}');
    expect(config.doesDatabaseExist(), isTrue);
  });

  test('toggleRequirePassword flips the value', () {
    final config = Configuration(testPath);
    expect(config.requirePassword, isFalse);
    config.toggleRequirePassword();
    expect(config.requirePassword, isTrue);
    config.toggleRequirePassword();
    expect(config.requirePassword, isFalse);
  });

  test('generateFromPassword returns a 32-byte key', () async {
    final config = Configuration(testPath);
    final key = await config.generateFromPassword('hunter2');
    final keyBytes = await key.extractBytes();
    expect(keyBytes.length, 32);
  });
}
