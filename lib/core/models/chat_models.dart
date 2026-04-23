class Conversation {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String? propertyImage;
  final String participant1Id;
  final String participant2Id;
  final String? lastMessage;
  final DateTime lastMessageAt;
  final DateTime createdAt;

  // Populated locally after fetch — not from Supabase directly
  String? otherUserName;
  String? otherUserPhone;

  Conversation({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    this.propertyImage,
    required this.participant1Id,
    required this.participant2Id,
    this.lastMessage,
    required this.lastMessageAt,
    required this.createdAt,
    this.otherUserName,
    this.otherUserPhone,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      propertyId: json['property_id'] ?? '',
      propertyTitle: json['property_title'] ?? '',
      propertyImage: json['property_image'],
      participant1Id: json['participant_1_id'] ?? '',
      participant2Id: json['participant_2_id'] ?? '',
      lastMessage: json['last_message'],
      lastMessageAt:
          DateTime.tryParse(json['last_message_at'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String otherParticipantId(String currentUserId) {
    return participant1Id == currentUserId ? participant2Id : participant1Id;
  }
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      content: json['content'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
