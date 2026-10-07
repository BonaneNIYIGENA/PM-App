import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Future<Database>? _databaseFuture;

  Future<Database> get database => _databaseFuture ??= _openDatabase();

  Future<Database> _openDatabase() async {
    try {
      if (kIsWeb) {
        // The web adapter persists SQLite data in browser IndexedDB.
        databaseFactory = databaseFactoryFfiWeb;
      }
      final databasePath = kIsWeb
          ? 'sprintmate_web.db'
          : p.join(await getDatabasesPath(), 'sprintmate.db');
      final db = await openDatabase(
        databasePath,
        version: 2,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            role TEXT NOT NULL,
            email TEXT NOT NULL,
            initials TEXT NOT NULL
          )
        ''');
          await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            assignee_id INTEGER,
            priority TEXT NOT NULL,
            deadline TEXT NOT NULL,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (assignee_id) REFERENCES members(id) ON DELETE SET NULL
          )
        ''');
          await db.execute(
            'CREATE TABLE IF NOT EXISTS app_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              'CREATE TABLE IF NOT EXISTS app_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
            );
          }
        },
      );
      await _seedIfEmpty(db);
      return db;
    } catch (_) {
      _databaseFuture = null;
      rethrow;
    }
  }

  Future<void> _seedIfEmpty(Database db) async {
    final initialized = await db.query(
      'app_meta',
      where: 'key = ?',
      whereArgs: ['demo_seeded'],
      limit: 1,
    );
    if (initialized.isNotEmpty) return;
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM members'),
        ) ??
        0;
    await db.transaction((txn) async {
      if (count > 0) {
        await txn.insert('app_meta', {'key': 'demo_seeded', 'value': 'true'});
        return;
      }
      final people = <TeamMember>[
        const TeamMember(
          name: 'Amina Uwase',
          role: 'Project lead',
          email: 'amina@team.dev',
          initials: 'AU',
        ),
        const TeamMember(
          name: 'Daniel Niyonzima',
          role: 'Flutter developer',
          email: 'daniel@team.dev',
          initials: 'DN',
        ),
        const TeamMember(
          name: 'Grace Mukamana',
          role: 'UI designer',
          email: 'grace@team.dev',
          initials: 'GM',
        ),
        const TeamMember(
          name: 'Eric Habimana',
          role: 'QA engineer',
          email: 'eric@team.dev',
          initials: 'EH',
        ),
      ];
      final ids = <int>[];
      for (final person in people) {
        ids.add(await txn.insert('members', person.toMap()));
      }
      final now = DateTime.now();
      final samples = <ProjectTask>[
        ProjectTask(
          title: 'Design the onboarding flow',
          description:
              'Prepare the first-run experience and user selection screens.',
          assigneeId: ids[2],
          priority: 'High',
          deadline: now.add(const Duration(days: 4)),
          status: 'inProgress',
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        ProjectTask(
          title: 'Review task form validation',
          description: 'Check required fields, deadline selection, and useful error messages.',
          assigneeId: ids[1],
          priority: 'Medium',
          deadline: now.add(const Duration(days: 1)),
          status: 'todo',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        ProjectTask(
          title: 'Fix dashboard progress calculation',
          description: 'Handle the empty task list and verify completed-task percentages.',
          assigneeId: ids[3],
          priority: 'High',
          deadline: now.subtract(const Duration(days: 1)),
          status: 'todo',
          createdAt: now.subtract(const Duration(days: 3)),
        ),
        ProjectTask(
          title: 'Create project color palette',
          description:
              'Document shared colors, typography, and reusable card styles.',
          assigneeId: ids[0],
          priority: 'Low',
          deadline: now.add(const Duration(days: 7)),
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 5)),
        ),
      ];
      for (final task in samples) {
        await txn.insert('tasks', task.toMap());
      }
      await txn.insert('app_meta', {'key': 'demo_seeded', 'value': 'true'});
    });
  }

  Future<List<ProjectTask>> loadTasks() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'deadline ASC');
    return rows.map(ProjectTask.fromMap).toList();
  }

  Future<int> saveTask(ProjectTask task) async {
    final db = await database;
    if (task.id == null) return db.insert('tasks', task.toMap());
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TeamMember>> loadMembers() async {
    final db = await database;
    final rows = await db.query('members', orderBy: 'name COLLATE NOCASE');
    return rows.map(TeamMember.fromMap).toList();
  }

  Future<int> saveMember(TeamMember member) async {
    final db = await database;
    if (member.id == null) return db.insert('members', member.toMap());
    return db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<void> deleteMember(int id) async {
    final db = await database;
    await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }
}
