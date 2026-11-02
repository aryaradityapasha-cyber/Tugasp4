import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/sqflite_helper.dart';
import '../widgets/task_dialog.dart';

class SqfliteTab extends StatefulWidget {
  const SqfliteTab({super.key});

  @override
  State<SqfliteTab> createState() => _SqfliteTabState();
}

class _SqfliteTabState extends State<SqfliteTab> {
  final SqfliteHelper _dbHelper = SqfliteHelper.instance;
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _dbHelper.getAllTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data SQLite: $e')),
        );
      }
    }
  }

  Future<void> _addTask(TaskModel task) async {
    await _dbHelper.insertTask(task);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil disimpan ke SQLite!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
    _loadTasks();
  }

  Future<void> _updateTask(TaskModel task) async {
    await _dbHelper.updateTask(task);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil diperbarui di SQLite!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
    _loadTasks();
  }

  Future<void> _deleteTask(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus tugas ini dari database SQLite?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteTask(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas berhasil dihapus dari SQLite!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      _loadTasks();
    }
  }

  Future<void> _seedDummyData() async {
    final dummies = [
      TaskModel(
        title: 'Praktikum 4 - CRUD SQFlite',
        description: 'Implementasi database SQLite lokal dan operasi CRUD di Flutter.',
        category: 'Praktikum',
        deadline: '2026-11-05',
        isCompleted: 1,
        createdAt: DateTime.now().toIso8601String(),
      ),
      TaskModel(
        title: 'Eksplorasi Hive NoSQL',
        description: 'Membandingkan kecepatan dan struktur data Hive vs SQFlite.',
        category: 'Praktikum',
        deadline: '2026-11-06',
        isCompleted: 0,
        createdAt: DateTime.now().toIso8601String(),
      ),
      TaskModel(
        title: 'Penyusunan Laporan Praktikum P4',
        description: 'Menuliskan ringkasan dan analisis perbandingan teknologi storage.',
        category: 'Kuliah',
        deadline: '2026-11-08',
        isCompleted: 0,
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];

    for (var d in dummies) {
      await _dbHelper.insertTask(d);
    }
    _loadTasks();
  }

  List<TaskModel> get _filteredTasks {
    return _tasks.where((t) {
      final matchCategory = _selectedCategory == 'Semua' || t.category == _selectedCategory;
      final matchQuery = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchQuery;
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Praktikum':
        return Colors.indigo;
      case 'Kuliah':
        return Colors.teal;
      case 'Tugas Akhir':
        return Colors.deepPurple;
      case 'Organisasi':
        return Colors.amber.shade800;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _tasks.length;
    final completed = _tasks.where((t) => t.isCompleted == 1).length;
    final pending = total - completed;
    final filtered = _filteredTasks;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: Column(
          children: [
            // Header Info & Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storage, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SQLite Database (SQFlite)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Relational Database • Tabel "tasks" • student_tasks.db',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      if (total == 0)
                        OutlinedButton.icon(
                          onPressed: _seedDummyData,
                          icon: const Icon(Icons.auto_fix_high, size: 16),
                          label: const Text('Isi Contoh', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Statistic Cards
                  Row(
                    children: [
                      _buildStatCard('Total Tugas', '$total', Icons.assignment, Colors.blue),
                      const SizedBox(width: 8),
                      _buildStatCard('Selesai', '$completed', Icons.check_circle, Colors.green),
                      const SizedBox(width: 8),
                      _buildStatCard('Pending', '$pending', Icons.pending_actions, Colors.orange),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar & Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari tugas SQLite...',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
              ),
            ),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  'Semua',
                  'Praktikum',
                  'Kuliah',
                  'Tugas Akhir',
                  'Organisasi',
                  'Umum'
                ].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      onSelected: (selected) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 16),

            // Task List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                total == 0
                                    ? 'Belum ada data tugas di SQFlite'
                                    : 'Tidak ada tugas yang cocok dengan filter',
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 12),
                              if (total == 0)
                                ElevatedButton.icon(
                                  onPressed: _seedDummyData,
                                  icon: const Icon(Icons.playlist_add),
                                  label: const Text('Tambahkan Data Demo SQLite'),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final task = filtered[index];
                            final isDone = task.isCompleted == 1;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isDone ? Colors.green.shade200 : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Checkbox for Status Toggle
                                        Checkbox(
                                          value: isDone,
                                          activeColor: Colors.green,
                                          onChanged: (val) {
                                            final updated = task.copyWith(
                                              isCompleted: (val ?? false) ? 1 : 0,
                                            );
                                            _updateTask(updated);
                                          },
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getCategoryColor(task.category)
                                                          .withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      task.category,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: _getCategoryColor(task.category),
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    'ID #${task.id}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                task.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  decoration: isDone
                                                      ? TextDecoration.lineThrough
                                                      : TextDecoration.none,
                                                  color: isDone
                                                      ? Colors.grey.shade600
                                                      : Colors.black87,
                                                ),
                                              ),
                                              if (task.description.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  task.description,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 14, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          task.deadline.isNotEmpty
                                              ? 'Deadline: ${task.deadline}'
                                              : 'Tanpa deadline',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const Spacer(),
                                        // Edit Button
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          color: Colors.blue,
                                          tooltip: 'Edit Tugas',
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => TaskDialog(
                                                task: task,
                                                onSave: _updateTask,
                                              ),
                                            );
                                          },
                                        ),
                                        // Delete Button
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20),
                                          color: Colors.red,
                                          tooltip: 'Hapus Tugas',
                                          onPressed: () => _deleteTask(task.id!),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => TaskDialog(
              onSave: _addTask,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah SQFlite'),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
