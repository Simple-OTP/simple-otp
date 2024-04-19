import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class DirectoryManager {
  Future<String> getInternalDirectoryPath();

  factory DirectoryManager.standard() => DirectoryManagerImpl();

  factory DirectoryManager.test() => TestDirectoryManager();
}

class TestDirectoryManager implements DirectoryManager {
  Directory? _directory;

  @override
  Future<String> getInternalDirectoryPath() async {
    if (_directory == null) {
      var tmpDir = await getTemporaryDirectory();
      _directory = tmpDir.createTempSync("test");
    }
    return _directory!.path;
  }
}

class DirectoryManagerImpl implements DirectoryManager {
  @override
  Future<String> getInternalDirectoryPath() async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }
}
