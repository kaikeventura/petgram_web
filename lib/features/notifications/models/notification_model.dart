enum NotificationType {
  postLike,
  postComment,
  friendshipRequest,
  friendshipAccepted,
  unknown,
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String message;
  final String link;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.link,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      type: _parseType(map['type']),
      message: map['message'] ?? '',
      link: map['link'] ?? '',
      isRead: map['isRead'] ?? true,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'POST_LIKE':
        return NotificationType.postLike;
      case 'POST_COMMENT':
        return NotificationType.postComment;
      case 'FRIENDSHIP_REQUEST':
        return NotificationType.friendshipRequest;
      case 'FRIENDSHIP_ACCEPTED':
        return NotificationType.friendshipAccepted;
      default:
        return NotificationType.unknown;
    }
  }
}
