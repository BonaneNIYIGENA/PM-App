import 'package:sqflite/sqflite.dart' show DatabaseFactory;

Future<DatabaseFactory> databaseFactoryForCurrentPlatform() =>
    throw UnsupportedError('SQLite is not configured for this platform.');

Future<String> databasePathForCurrentPlatform() =>
    throw UnsupportedError('SQLite is not configured for this platform.');
