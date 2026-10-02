class SupportTicket {
  final String ticketId;
  final String subject;
  final String category;
  final String status;
  final int unreadReplies;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  SupportTicket({
    required this.ticketId,
    required this.subject,
    required this.category,
    required this.status,
    required this.unreadReplies,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      ticketId: json['ticketId'] ?? '',
      subject: json['subject'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? '',
      unreadReplies: json['unreadReplies'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastUpdatedAt: DateTime.tryParse(json['lastUpdatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'subject': subject,
      'category': category,
      'status': status,
      'unreadReplies': unreadReplies,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }
}

class SupportTicketMessage {
  final String id;
  final String senderType; // 'USER', 'SUPPORT', 'SYSTEM'
  final String senderName;
  final String message;
  final DateTime createdAt;

  SupportTicketMessage({
    required this.id,
    required this.senderType,
    required this.senderName,
    required this.message,
    required this.createdAt,
  });

  factory SupportTicketMessage.fromJson(Map<String, dynamic> json) {
    return SupportTicketMessage(
      id: json['id'] ?? '',
      senderType: json['senderType'] ?? 'SYSTEM',
      senderName: json['senderName'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class SupportTicketDetail {
  final String ticketId;
  final String subject;
  final String category;
  final String status;
  final List<SupportTicketMessage> messages;

  SupportTicketDetail({
    required this.ticketId,
    required this.subject,
    required this.category,
    required this.status,
    required this.messages,
  });

  factory SupportTicketDetail.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List? ?? [];
    List<SupportTicketMessage> messages = messagesList.map((m) => SupportTicketMessage.fromJson(m)).toList();
    
    return SupportTicketDetail(
      ticketId: json['ticketId'] ?? '',
      subject: json['subject'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? '',
      messages: messages,
    );
  }
}
