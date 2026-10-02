class TaskModel {
  final int id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String priority;
  final String status;
  final String? relatedEntityType;
  final int? relatedEntityId;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.priority,
    required this.status,
    this.relatedEntityType,
    this.relatedEntityId,
    this.completedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      priority: json['priority'] ?? 'MEDIUM',
      status: json['status'] ?? 'PENDING',
      relatedEntityType: json['relatedEntityType'],
      relatedEntityId: json['relatedEntityId'],
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'status': status,
      'relatedEntityType': relatedEntityType,
      'relatedEntityId': relatedEntityId,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
