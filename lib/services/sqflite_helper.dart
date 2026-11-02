import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class SqfliteHelper {
  static final SqfliteHelper instance = SqfliteHelper._init();
  static Database? _database;

  SqfliteHelper._init();

  /// Inisialisasi factory FFI untuk platform desktop (Windows / Linux)
  static void initializePlatform() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    initializePlatform();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Membuat skema tabel database
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        deadline TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // ==========================================
  // OPERASI CRUD (CREATE, READ, UPDATE, DELETE)
  // ==========================================

  /// 1. CREATE: Menambahkan data tugas baru ke dalam database
  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 2. READ: Mengambil seluruh data tugas dari database (diurutkan terbaru lebih dulu)
  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final result = await db.query(
      'tasks',
      orderBy: 'id DESC',
    );
    return result.map((json) => TaskModel.fromMap(json)).toList();
  }

  /// 2b. READ: Mengambil satu data tugas berdasarkan ID
  Future<TaskModel?> getTaskById(int id) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TaskModel.fromMap(maps.first);
    }
    return null;
  }

  /// 3. UPDATE: Mengubah data tugas yang sudah ada berdasarkan ID
  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// 4. DELETE: Menghapus data tugas berdasarkan ID
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Menghapus seluruh data tugas (reset data)
  Future<int> clearAllTasks() async {
    final db = await database;
    return await db.delete('tasks');
  }

  /// Menutup koneksi database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
