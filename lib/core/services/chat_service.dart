import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_models.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get or create a conversation between two users about a property.
  // This is idempotent — safe to call every time user taps "Send Message".
  Future<Conversation> getOrCreateConversation({
    required String currentUserId,
    required String ownerId,
    required String propertyId,
    required String propertyTitle,
    String? propertyImage,
  }) async {
    // Always store participant_1 as the smaller ID so the unique constraint works
    // regardless of who initiates the conversation.
    final p1 = currentUserId.compareTo(ownerId) < 0 ? currentUserId : ownerId;
    final p2 = currentUserId.compareTo(ownerId) < 0 ? ownerId : currentUserId;

    // Check if conversation already exists
    final existing = await _client
        .from('conversations')
        .select()
        .eq('property_id', propertyId)
        .eq('participant_1_id', p1)
        .eq('participant_2_id', p2)
        .maybeSingle();

    if (existing != null) {
      return Conversation.fromJson(existing);
    }

    // Create new conversation
    final created = await _client
        .from('conversations')
        .insert({
          'property_id': propertyId,
          'property_title': propertyTitle,
          'property_image': propertyImage,
          'participant_1_id': p1,
          'participant_2_id': p2,
        })
        .select()
        .single();

    return Conversation.fromJson(created);
  }

  // Fetch all conversations for a user, newest first
  Future<List<Conversation>> getConversations(String userId) async {
    final response = await _client
        .from('conversations')
        .select()
        .or('participant_1_id.eq.$userId,participant_2_id.eq.$userId')
        .order('last_message_at', ascending: false);

    return (response as List).map((e) => Conversation.fromJson(e)).toList();
  }

  // Fetch messages for a conversation
  Future<List<Message>> getMessages(String conversationId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return (response as List).map((e) => Message.fromJson(e)).toList();
  }

  // Send a message and update conversation's last_message
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    final messageData = await _client
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': senderId,
          'content': content.trim(),
        })
        .select()
        .single();

    // Update last_message on the conversation
    await _client
        .from('conversations')
        .update({
          'last_message': content.trim(),
          'last_message_at': DateTime.now().toIso8601String(),
        })
        .eq('id', conversationId);

    return Message.fromJson(messageData);
  }

  // Mark all messages in a conversation as read (not from current user)
  Future<void> markAsRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .eq('is_read', false)
        .neq('sender_id', currentUserId);
  }

  // Real-time stream of new messages in a conversation
  Stream<List<Message>> messagesStream(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map((e) => Message.fromJson(e)).toList());
  }

  // Real-time stream of conversations (inbox updates)
  Stream<List<Conversation>> conversationsStream(String userId) {
    return _client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false)
        .map((rows) {
          final all = rows.map((e) => Conversation.fromJson(e)).toList();
          return all
              .where(
                (c) => c.participant1Id == userId || c.participant2Id == userId,
              )
              .toList();
        });
  }

  // Unread message count across all conversations for a user
  Future<int> getUnreadCount(String userId) async {
    final conversations = await getConversations(userId);
    if (conversations.isEmpty) return 0;

    final conversationIds = conversations.map((c) => c.id).toList();

    final response = await _client
        .from('messages')
        .select('id')
        .inFilter('conversation_id', conversationIds)
        .eq('is_read', false)
        .neq('sender_id', userId);

    return (response as List).length;
  }
}
