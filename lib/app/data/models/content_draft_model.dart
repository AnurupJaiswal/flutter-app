class ContentDraftModel {
  final dynamic id;
  final dynamic accountId;
  final String title;
  final String contentType; // SHORT, LONG_FORM, REEL
  final String status; // DRAFT, POSTED, SCHEDULED
  final DateTime? scheduledAt; // Local time zone representation
  final String? rawScheduledAt; // Raw UTC string from backend
  final String? scriptData;
  final dynamic copilotPlanId;
  final String? createdAt;
  final String? updatedAt;

  ContentDraftModel({
    required this.id,
    this.accountId,
    required this.title,
    this.contentType = 'SHORT',
    this.status = 'DRAFT',
    this.scheduledAt,
    this.rawScheduledAt,
    this.scriptData,
    this.copilotPlanId,
    this.createdAt,
    this.updatedAt,
  });

  bool get isScheduled =>
      status.toUpperCase() == 'SCHEDULED' || scheduledAt != null;
  bool get isPosted => status.toUpperCase() == 'POSTED';
  bool get isMissed => status.toUpperCase() == 'MISSED';
  bool get isDraft => status.toUpperCase() == 'DRAFT';

  /// Returns normalized display status string for UI badge ("Scheduled", "Posted", "Missed", "Draft")
  String get statusDisplay {
    if (isPosted) return "Posted";
    if (isMissed) return "Missed";
    if (isScheduled && scheduledAt != null) return "Scheduled";
    return "Draft";
  }

  /// Format platform tag based on contentType ("YouTube Shorts", "Instagram Reel", "Long-Form Video")
  String get platformTag {
    switch (contentType.toUpperCase()) {
      case 'SHORT':
        return "YouTube Shorts";
      case 'REEL':
        return "Instagram Reel";
      case 'LONG_FORM':
      default:
        return "Long-Form Video";
    }
  }

  /// Format platform name ("YouTube", "Instagram")
  String get platform {
    if (contentType.toUpperCase() == 'REEL') return "Instagram";
    return "YouTube";
  }

  factory ContentDraftModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    String? rawDate =
        json['scheduledAt']?.toString() ?? json['scheduledDate']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        parsedDate = DateTime.parse(rawDate).toLocal();
      } catch (_) {
        parsedDate = null;
      }
    }

    String parsedStatus = json['status']?.toString().toUpperCase() ?? 'DRAFT';
    if (parsedDate != null && parsedStatus == 'DRAFT') {
      parsedStatus = 'SCHEDULED';
    }

    return ContentDraftModel(
      id: json['id'] ?? json['draftId'],
      accountId: json['accountId'] ?? json['connectedAccountId'],
      title: json['title']?.toString() ?? 'Untitled Post',
      contentType: json['contentType']?.toString().toUpperCase() ?? 'SHORT',
      status: parsedStatus,
      scheduledAt: parsedDate,
      rawScheduledAt: rawDate,
      scriptData: json['scriptData']?.toString(),
      copilotPlanId: json['copilotPlanId'],
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'title': title,
      'contentType': contentType,
      'status': status,
      'scheduledAt': rawScheduledAt ?? scheduledAt?.toUtc().toIso8601String(),
      'scriptData': scriptData,
      'copilotPlanId': copilotPlanId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ContentDraftModel copyWith({
    dynamic id,
    dynamic accountId,
    String? title,
    String? contentType,
    String? status,
    DateTime? scheduledAt,
    String? rawScheduledAt,
    String? scriptData,
    dynamic copilotPlanId,
    String? createdAt,
    String? updatedAt,
  }) {
    return ContentDraftModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      title: title ?? this.title,
      contentType: contentType ?? this.contentType,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      rawScheduledAt: rawScheduledAt ?? this.rawScheduledAt,
      scriptData: scriptData ?? this.scriptData,
      copilotPlanId: copilotPlanId ?? this.copilotPlanId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
