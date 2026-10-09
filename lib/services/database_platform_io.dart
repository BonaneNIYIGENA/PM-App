import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<DatabaseFactory> databaseFactoryForCurrentPlatform() async {
  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    return databaseFactoryFfi;
  }

  // Android, iOS, and macOS use the native sqflite plugin.
  return sqflite.databaseFactory;
}

Future<String> databasePathForCurrentPlatform() async {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    final directory = await getApplicationSupportDirectory();
    return p.join(directory.path, 'taskms.db');
  }

  return p.join(await sqflite.getDatabasesPath(), 'taskms.db');
}
