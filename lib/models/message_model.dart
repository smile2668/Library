class MessageModel {
  final String id;
  final String libraryId;
  final String senderId;
  final String? receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.libraryId,
    required this.senderId,
    this.receiverId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  bool get isBroadcast => receiverId == null;

  Map<String, dynamic> toMap() => {
        'library_id': libraryId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
      };

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) => MessageModel(
        id: id,
        libraryId: map['library_id'] as String? ?? '',
        senderId: map['sender_id'] as String? ?? '',
        receiverId: map['receiver_id'] as String?,
        content: map['content'] as String? ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
        isRead: map['is_read'] as bool? ?? false,
      );

  MessageModel copyWith({
    String? id,
    String? libraryId,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
  }) =>
      MessageModel(
        id: id ?? this.id,
        libraryId: libraryId ?? this.libraryId,
        senderId: senderId ?? this.senderId,
        receiverId: receiverId ?? this.receiverId,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        isRead: isRead ?? this.isRead,
      );
}
