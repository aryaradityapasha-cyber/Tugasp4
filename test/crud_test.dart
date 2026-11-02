import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:hive/hive.dart';
import 'package:tugas_crud/models/task_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SQFlite CRUD Operations Test', () {
    late Database db;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Inisialisasi in-memory SQLite database untuk testing
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
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
    });

    tearDown(() async {
      await db.close();
    });

    test('1. CREATE (Insert) task ke SQLite', () async {
      final task = TaskModel(
        title: 'Tugas Praktikum 4 Mopro',
        description: 'Implementasi SQFlite dan Hive',
        category: 'Praktikum',
        deadline: '2026-11-05',
        createdAt: DateTime.now().toIso8601String(),
      );

      final id = await db.insert('tasks', task.toMap());
      expect(id, isPositive);
    });

    test('2. READ (Select) task dari SQLite', () async {
      final task = TaskModel(
        title: 'Belajar Basis Data Mobile',
        description: 'Eksplorasi local storage SQLite',
        category: 'Kuliah',
        deadline: '2026-11-10',
        createdAt: DateTime.now().toIso8601String(),
      );

      final id = await db.insert('tasks', task.toMap());

      final results = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
      expect(results.length, 1);
      final retrieved = TaskModel.fromMap(results.first);
      expect(retrieved.title, 'Belajar Basis Data Mobile');
      expect(retrieved.category, 'Kuliah');
    });

    test('3. UPDATE task pada SQLite', () async {
      final task = TaskModel(
        title: 'Tugas Lama',
        description: 'Deskripsi lama',
        category: 'Umum',
        deadline: '2026-11-01',
        createdAt: DateTime.now().toIso8601String(),
      );

      final id = await db.insert('tasks', task.toMap());

      final updatedTask = task.copyWith(
        id: id,
        title: 'Tugas Baru Diperbarui',
        isCompleted: 1,
      );

      final count = await db.update(
        'tasks',
        updatedTask.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(count, 1);

      final results = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
      final retrieved = TaskModel.fromMap(results.first);
      expect(retrieved.title, 'Tugas Baru Diperbarui');
      expect(retrieved.isCompleted, 1);
    });

    test('4. DELETE task dari SQLite', () async {
      final task = TaskModel(
        title: 'Tugas yang akan dihapus',
        description: 'Dihapus setelah selesai',
        category: 'Organisasi',
        deadline: '2026-11-02',
        createdAt: DateTime.now().toIso8601String(),
      );

      final id = await db.insert('tasks', task.toMap());

      final count = await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
      expect(count, 1);

      final results = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
      expect(results.isEmpty, isTrue);
    });
  });

  group('Hive Alternative Storage CRUD Operations Test', () {
    late Directory tempDir;
    late Box box;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(tempDir.path);
      box = await Hive.openBox('test_tasks_box');
    });

    tearDown(() async {
      await box.close();
      await tempDir.delete(recursive: true);
    });

    test('1. CREATE (Put/Add) task di Hive', () async {
      final task = TaskModel(
        title: 'Belajar Hive NoSQL',
        description: 'Local storage alternatif di Flutter',
        category: 'Praktikum',
        deadline: '2026-11-06',
        createdAt: DateTime.now().toIso8601String(),
      );

      final key = await box.add(task.toMap());
      expect(key, isNotNull);
      expect(box.length, 1);
    });

    test('2. READ task dari Hive', () async {
      final task = TaskModel(
        title: 'Membaca Dokumentasi Hive',
        description: 'Key-value database cepat',
        category: 'Kuliah',
        deadline: '2026-11-08',
        createdAt: DateTime.now().toIso8601String(),
      );

      final key = await box.add(task.toMap());
      final retrievedMap = Map<String, dynamic>.from(box.get(key));
      final retrieved = TaskModel.fromMap(retrievedMap);

      expect(retrieved.title, 'Membaca Dokumentasi Hive');
      expect(retrieved.category, 'Kuliah');
    });

    test('3. UPDATE task di Hive', () async {
      final task = TaskModel(
        title: 'Draft Laporan',
        description: 'Belum final',
        category: 'Praktikum',
        deadline: '2026-11-09',
        createdAt: DateTime.now().toIso8601String(),
      );

      final key = await box.add(task.toMap());

      final updatedTask = task.copyWith(
        id: key,
        title: 'Laporan Final P4 Mopro',
        isCompleted: 1,
      );

      await box.put(key, updatedTask.toMap());

      final retrievedMap = Map<String, dynamic>.from(box.get(key));
      final retrieved = TaskModel.fromMap(retrievedMap);
      expect(retrieved.title, 'Laporan Final P4 Mopro');
      expect(retrieved.isCompleted, 1);
    });

    test('4. DELETE task di Hive', () async {
      final task = TaskModel(
        title: 'Tugas Sementara',
        description: 'Akan dihapus',
        category: 'Umum',
        deadline: '2026-11-12',
        createdAt: DateTime.now().toIso8601String(),
      );

      final key = await box.add(task.toMap());
      expect(box.length, 1);

      await box.delete(key);
      expect(box.length, 0);
    });
  });
}
