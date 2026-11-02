class TaskModel {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String deadline;
  final int isCompleted; // 0: Belum selesai, 1: Selesai
  final String createdAt;

  TaskModel({
    this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.deadline,
    this.isCompleted = 0,
    required this.createdAt,
  });

  // Convert Model to Map (untuk disimpan ke SQFlite / Hive)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category,
      'deadline': deadline,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Convert Map to Model (dari SQFlite / Hive)
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id']?.toString() ?? ''),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Umum',
      deadline: map['deadline'] as String? ?? '',
      isCompleted: (map['isCompleted'] is int)
          ? map['isCompleted'] as int
          : (int.tryParse(map['isCompleted']?.toString() ?? '0') ?? 0),
      createdAt: map['createdAt'] as String? ?? '',
    );
  }

  // Copy with method untuk mempermudah update status / properti
  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? deadline,
    int? isCompleted,
    String? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
