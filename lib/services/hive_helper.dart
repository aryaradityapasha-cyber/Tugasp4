import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class HiveHelper {
  static final HiveHelper instance = HiveHelper._init();
  static const String boxName = 'student_tasks_box';

  HiveHelper._init();

  /// Inisialisasi Hive dan buka Box untuk penyimpanan data
  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  Box get _box => Hive.box(boxName);

  // ==========================================
  // OPERASI CRUD MENGGUNAKAN HIVE (NoSQL KEY-VALUE)
  // ==========================================

  /// 1. CREATE: Menyimpan data ke Hive Box
  Future<int> insertTask(TaskModel task) async {
    final map = task.toMap();
    // Hive .add() menghasilkan auto-increment integer key
    final key = await _box.add(map);
    // Simpan id yang dihasilkan ke dalam map
    map['id'] = key;
    await _box.put(key, map);
    return key;
  }

  /// 2. READ: Mengambil seluruh data tugas dari Hive Box
  List<TaskModel> getAllTasks() {
    final List<TaskModel> tasks = [];
    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value != null && value is Map) {
        final map = Map<String, dynamic>.from(value);
        map['id'] = key is int ? key : int.tryParse(key.toString());
        tasks.add(TaskModel.fromMap(map));
      }
    }
    // Mengembalikan list dengan urutan terbaru terlebih dahulu
    return tasks.reversed.toList();
  }

  /// 3. UPDATE: Mengubah data pada Hive Box berdasarkan key (ID)
  Future<void> updateTask(TaskModel task) async {
    if (task.id == null) return;
    await _box.put(task.id, task.toMap());
  }

  /// 4. DELETE: Menghapus data dari Hive Box berdasarkan key (ID)
  Future<void> deleteTask(int id) async {
    await _box.delete(id);
  }

  /// Menghapus seluruh data dalam Hive Box
  Future<void> clearAllTasks() async {
    await _box.clear();
  }
}
