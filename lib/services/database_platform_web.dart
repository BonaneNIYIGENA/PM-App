import 'package:sqflite/sqflite.dart' show DatabaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<DatabaseFactory> databaseFactoryForCurrentPlatform() async =>
    databaseFactoryFfiWeb;

Future<String> databasePathForCurrentPlatform() async => 'taskms_web.db';
