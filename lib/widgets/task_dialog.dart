import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskDialog extends StatefulWidget {
  final TaskModel? task;
  final Function(TaskModel) onSave;

  const TaskDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _deadlineToController;
  late String _selectedCategory;
  late int _isCompleted;

  final List<String> _categories = [
    'Praktikum',
    'Kuliah',
    'Tugas Akhir',
    'Organisasi',
    'Umum',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _deadlineToController = TextEditingController(
      text: t?.deadline.isNotEmpty == true
          ? t!.deadline
          : DateTime.now().add(const Duration(days: 3)).toIso8601String().substring(0, 10),
    );
    _selectedCategory = t != null && _categories.contains(t.category) ? t.category : 'Praktikum';
    _isCompleted = t?.isCompleted ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _deadlineToController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _deadlineToController.text = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final task = TaskModel(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        deadline: _deadlineToController.text.trim(),
        isCompleted: _isCompleted,
        createdAt: widget.task?.createdAt ?? DateTime.now().toIso8601String(),
      );

      widget.onSave(task);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit_note : Icons.add_task,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(isEditing ? 'Edit Tugas' : 'Tambah Tugas Baru'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 450,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Tugas / Catatan *',
                    hintText: 'Contoh: Laporan Praktikum P4',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Judul tugas wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _deadlineToController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tenggat Waktu (Deadline)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: _pickDate,
                    ),
                  ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi / Catatan',
                    hintText: 'Tuliskan detail tugas atau instruksi tambahan...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Status Selesai'),
                    subtitle: Text(
                      _isCompleted == 1 ? 'Sudah Selesai' : 'Belum Selesai',
                      style: TextStyle(
                        color: _isCompleted == 1 ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _isCompleted == 1,
                    onChanged: (val) {
                      setState(() {
                        _isCompleted = val ? 1 : 0;
                      });
                    },
                    secondary: Icon(
                      _isCompleted == 1 ? Icons.check_circle : Icons.pending,
                      color: _isCompleted == 1 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save),
          label: Text(isEditing ? 'Perbarui' : 'Simpan'),
        ),
      ],
    );
  }
}
