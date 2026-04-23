import 'package:flutter/material.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  User? _currentUser;
  List<Conversation> _conversations = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  int _unreadCount = 0;

  User? get currentUser => _currentUser;
  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  Future<void> init() async {
    _currentUser = await _authService.getCurrentUser();
    if (_currentUser != null) {
      await loadConversations();
      await refreshUnreadCount();
    }
    notifyListeners();
  }

  Future<void> loadConversations() async {
    if (_currentUser == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _conversations = await _chatService.getConversations(_currentUser!.id);
    } catch (e) {
      _errorMessage = 'Failed to load conversations';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String conversationId) async {
    if (_currentUser == null) return;
    _isLoading = true;
    _messages = [];
    notifyListeners();

    try {
      _messages = await _chatService.getMessages(conversationId);
      await _chatService.markAsRead(
        conversationId: conversationId,
        currentUserId: _currentUser!.id,
      );
      await refreshUnreadCount();
    } catch (e) {
      _errorMessage = 'Failed to load messages';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Conversation?> openOrCreateConversation({
    required String ownerId,
    required String propertyId,
    required String propertyTitle,
    String? propertyImage,
  }) async {
    if (_currentUser == null) return null;

    // Prevent user from messaging themselves
    if (_currentUser!.id == ownerId) return null;

    try {
      final conversation = await _chatService.getOrCreateConversation(
        currentUserId: _currentUser!.id,
        ownerId: ownerId,
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        propertyImage: propertyImage,
      );
      return conversation;
    } catch (e) {
      _errorMessage = 'Could not open conversation';
      notifyListeners();
      return null;
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    if (_currentUser == null || content.trim().isEmpty) return;
    _isSending = true;
    notifyListeners();

    try {
      final message = await _chatService.sendMessage(
        conversationId: conversationId,
        senderId: _currentUser!.id,
        content: content,
      );
      _messages = [..._messages, message];
    } catch (e) {
      _errorMessage = 'Failed to send message';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Stream<List<Message>> messagesStream(String conversationId) {
    return _chatService.messagesStream(conversationId);
  }

  Stream<List<Conversation>> conversationsStream() {
    if (_currentUser == null) return const Stream.empty();
    return _chatService.conversationsStream(_currentUser!.id);
  }

  Future<void> refreshUnreadCount() async {
    if (_currentUser == null) return;
    _unreadCount = await _chatService.getUnreadCount(_currentUser!.id);
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}