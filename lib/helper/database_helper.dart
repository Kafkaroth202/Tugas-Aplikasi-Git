import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class DatabaseHelper {
  // Private constructor: no one outside this class can create a new object
  DatabaseHelper._();

  // The one and only instance, used by every other class
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'tasklist.db';
  static const _dbVersion = 1;
  static const tableTask = 'tasks';

  Database? _database;

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTask
      (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        time TEXT NOT NULL,
        priority TEXT NOT NULL,
        category TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.insert(
      tableTask,
      const Task(
        name: 'Menyelesaikan Tugas',
        description: 'Merapikan dan mengirim laporan mingguan',
        time: '09.00',
        priority: 'Sedang',
        category: 'Pekerjaan',
        isDone: true,
      ).toMap(),
    );
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(tableTask, task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final rows = await db.query(tableTask, orderBy: 'time ASC');
    return rows.map(Task.fromMap).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      tableTask,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete(
      tableTask,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

} 