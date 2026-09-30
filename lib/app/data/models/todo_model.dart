class TodoItemModel {
  final dynamic id;
  final dynamic connectedAccountId;
  final dynamic channelAuditId;
  final String title;
  final String? subtitle;
  final String? details;
  final String priority; // HIGH, MEDIUM, LOW
  final String tag;
  final String expectedOutcome;
  final bool isDone;
  final String? dueDate;
  final String? createdAt;

  TodoItemModel({
    required this.id,
    this.connectedAccountId,
    this.channelAuditId,
    required this.title,
    this.subtitle,
    this.details,
    this.priority = 'HIGH',
    this.tag = 'General',
    this.expectedOutcome = '',
    this.isDone = false,
    this.dueDate,
    this.createdAt,
  });

  /// Priority normalized string ('HIGH', 'MEDIUM', 'LOW')
  String get normalizedPriority {
    final p = priority.toUpperCase();
    if (p == 'HIGH' || p == 'RED') return 'HIGH';
    if (p == 'MEDIUM' || p == 'ORANGE') return 'MEDIUM';
    if (p == 'LOW' || p == 'YELLOW') return 'LOW';
    return 'HIGH';
  }

  factory TodoItemModel.fromJson(Map<String, dynamic> json) {
    String rawPriority =
        (json['priority'] ?? json['priorityLevel'])?.toString().toUpperCase() ??
        'HIGH';
    if (rawPriority == 'ORANGE') rawPriority = 'MEDIUM';
    if (rawPriority == 'RED') rawPriority = 'HIGH';
    if (rawPriority == 'YELLOW') rawPriority = 'LOW';

    return TodoItemModel(
      id: json['id'] ?? json['todoId'],
      connectedAccountId: json['connectedAccountId'] ?? json['accountId'],
      channelAuditId: json['channelAuditId'] ?? json['auditId'],
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      details: json['details']?.toString(),
      priority: rawPriority,
      tag: json['tag']?.toString() ?? 'General',
      expectedOutcome:
          json['expectedOutcome']?.toString() ??
          json['impact']?.toString() ??
          '',
      isDone:
          json['isDone'] == true ||
          json['status']?.toString().toUpperCase() == 'COMPLETED' ||
          json['status']?.toString().toUpperCase() == 'DONE',
      dueDate: json['dueDate']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'connectedAccountId': connectedAccountId,
      'channelAuditId': channelAuditId,
      'title': title,
      'subtitle': subtitle,
      'details': details,
      'priority': priority,
      'tag': tag,
      'expectedOutcome': expectedOutcome,
      'isDone': isDone,
      'dueDate': dueDate,
      'createdAt': createdAt,
    };
  }

  TodoItemModel copyWith({
    dynamic id,
    dynamic connectedAccountId,
    dynamic channelAuditId,
    String? title,
    String? subtitle,
    String? details,
    String? priority,
    String? tag,
    String? expectedOutcome,
    bool? isDone,
    String? dueDate,
    String? createdAt,
  }) {
    return TodoItemModel(
      id: id ?? this.id,
      connectedAccountId: connectedAccountId ?? this.connectedAccountId,
      channelAuditId: channelAuditId ?? this.channelAuditId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      details: details ?? this.details,
      priority: priority ?? this.priority,
      tag: tag ?? this.tag,
      expectedOutcome: expectedOutcome ?? this.expectedOutcome,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ConvertTodoResult {
  final String status; // 'CREATED', 'DUPLICATE', or 'FAILED'
  final dynamic todoId;
  final String? message;

  ConvertTodoResult({required this.status, this.todoId, this.message});

  bool get isCreated => status == 'CREATED';
  bool get isDuplicate => status == 'DUPLICATE';
  bool get isSuccess => isCreated || isDuplicate;
}
