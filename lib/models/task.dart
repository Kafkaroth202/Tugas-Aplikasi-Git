class Task {
  // Field
  final int? id;
  final String name;
  final String description;
  final String time; 
  final String priority;
  final String category;
  final bool isDone;

  // Constructor
  const Task({
    this.id,
    required this.name,
    required this.description,
    required this.time,
    required this.priority,
    required this.category,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'time': time,
      'priority': priority,
      'category': category,
      'is_done': isDone ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      time: map['time'] as String,
      priority: map['priority'] as String,
      category: map['category'] as String,
      isDone: map['is_done'] == 1,
    );
  }

  Task copyWith({bool? isDone}) {
    return Task(
      id: id,
      name: name,
      description: description,
      time: time,
      priority: priority,
      category: category,
      isDone: isDone ?? this.isDone,
    );
  }
}