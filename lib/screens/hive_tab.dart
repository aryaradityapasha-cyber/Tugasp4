import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/hive_helper.dart';
import '../widgets/task_dialog.dart';

class HiveTab extends StatefulWidget {
  const HiveTab({super.key});

  @override
  State<HiveTab> createState() => _HiveTabState();
}

class _HiveTabState extends State<HiveTab> {
  final HiveHelper _hiveHelper = HiveHelper.instance;
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() => _isLoading = true);
    try {
      final tasks = _hiveHelper.getAllTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data Hive: $e')),
        );
      }
    }
  }

  Future<void> _addTask(TaskModel task) async {
    await _hiveHelper.insertTask(task);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil disimpan ke Hive NoSQL!'),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 2),
        ),
      );
    }
    _loadTasks();
  }

  Future<void> _updateTask(TaskModel task) async {
    await _hiveHelper.updateTask(task);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil diperbarui di Hive!'),
          backgroundColor: Colors.orange,
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
        content: const Text('Apakah Anda yakin ingin menghapus data ini dari Hive Box?'),
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
      await _hiveHelper.deleteTask(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas berhasil dihapus dari Hive!'),
            backgroundColor: Colors.redAccent,
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
        title: 'Eksplorasi Hive Box',
        description: 'Menyimpan format key-value binary kecepatan tinggi tanpa SQL query.',
        category: 'Praktikum',
        deadline: '2026-11-07',
        isCompleted: 1,
        createdAt: DateTime.now().toIso8601String(),
      ),
      TaskModel(
        title: 'Benchmark SQLite vs Hive',
        description: 'Uji waktu baca dan tulis data pada sistem mobile/desktop.',
        category: 'Kuliah',
        deadline: '2026-11-09',
        isCompleted: 0,
        createdAt: DateTime.now().toIso8601String(),
      ),
      TaskModel(
        title: 'Review Perbedaan Relational vs Document',
        description: 'Menganalisis skema ketat SQLite vs skema fleksibel NoSQL.',
        category: 'Tugas Akhir',
        deadline: '2026-11-15',
        isCompleted: 0,
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];

    for (var d in dummies) {
      await _hiveHelper.insertTask(d);
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
        onRefresh: () async => _loadTasks(),
        child: Column(
          children: [
            // Header Info & Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade100.withValues(alpha: 0.5),
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
                          color: Colors.amber.shade800,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.dataset, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Alternatif: Hive (NoSQL Key-Value)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Pure Dart Fast Storage • Box "student_tasks_box"',
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
                      _buildStatCard('Total Hive', '$total', Icons.assignment, Colors.amber.shade900),
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
                  hintText: 'Cari tugas Hive...',
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
                              Icon(Icons.layers_clear, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                total == 0
                                    ? 'Belum ada data tugas di Hive Box'
                                    : 'Tidak ada tugas yang cocok dengan filter',
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 12),
                              if (total == 0)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber.shade700,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: _seedDummyData,
                                  icon: const Icon(Icons.playlist_add),
                                  label: const Text('Tambahkan Data Demo Hive'),
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
                                  color: isDone ? Colors.green.shade200 : Colors.amber.shade200,
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
                                                    'Key #${task.id}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.amber.shade900,
                                                      fontWeight: FontWeight.bold,
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
                                          tooltip: 'Edit Tugas Hive',
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
                                          tooltip: 'Hapus Tugas Hive',
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
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => TaskDialog(
              onSave: _addTask,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Hive'),
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
