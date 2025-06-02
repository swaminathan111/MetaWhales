import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'openrouter_service.dart';
import 'rag_chat_service.dart';
import '../../auth/services/profile_service.dart';

class ChatPersistenceService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();

  /// Get or create current active conversation for user
  Future<String> getCurrentConversationId() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Ensure user profile exists before creating conversation
      final profileService = ProfileService();
      await profileService.ensureUserProfile();
      _logger.d('User profile verified for conversation creation');

      // Check for existing active conversation
      final response = await _supabase
          .from('chat_conversations')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .order('last_message_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return response['id'] as String;
      }

      // Create new conversation if none exists
      final newConversation = await _supabase
          .from('chat_conversations')
          .insert({
            'user_id': user.id,
            'title': 'Chat with CardSense AI',
            'status': 'active',
          })
          .select('id')
          .single();

      _logger.i('Created new conversation: ${newConversation['id']}');
      return newConversation['id'] as String;
    } catch (e) {
      _logger.e('Failed to get conversation ID: $e');
      rethrow;
    }
  }

  /// Load conversation history for current user
  Future<List<ChatMessage>> loadConversationHistory({
    String? conversationId,
    int limit = 50,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final currentConversationId =
          conversationId ?? await getCurrentConversationId();

      final response = await _supabase
          .from('chat_messages')
          .select('*')
          .eq('conversation_id', currentConversationId)
          .order('created_at', ascending: true)
          .limit(limit);

      final messages = response.map<ChatMessage>((messageData) {
        return ChatMessage(
          isUser: messageData['sender_type'] == 'user',
          message: messageData['message'],
          timestamp: DateTime.parse(messageData['created_at']),
          model: messageData['ai_model_used'],
        );
      }).toList();

      _logger.i(
          'Loaded ${messages.length} messages from conversation $currentConversationId');
      return messages;
    } catch (e) {
      _logger.e('Failed to load conversation history: $e');
      return [];
    }
  }

  /// Save a message to the database
  Future<void> saveMessage({
    required String message,
    required bool isUser,
    String? conversationId,
    String? aiModel,
    int? responseTimeMs,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final currentConversationId =
          conversationId ?? await getCurrentConversationId();

      await _supabase.from('chat_messages').insert({
        'conversation_id': currentConversationId,
        'user_id': user.id,
        'message': message,
        'sender_type': isUser ? 'user' : 'assistant',
        'message_type': 'text',
        'ai_model_used': aiModel,
        'ai_response_time_ms': responseTimeMs,
      });

      // Update conversation last_message_at
      await _supabase.from('chat_conversations').update({
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', currentConversationId);

      _logger.d('Saved message to conversation $currentConversationId');
    } catch (e) {
      _logger.e('Failed to save message: $e');
      rethrow;
    }
  }

  /// Get all conversations for current user
  Future<List<ChatConversation>> getConversations({int limit = 20}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('chat_conversations')
          .select('*')
          .eq('user_id', user.id)
          .neq('status', 'deleted')
          .order('last_message_at', ascending: false)
          .limit(limit);

      return response.map<ChatConversation>((data) {
        return ChatConversation(
          id: data['id'],
          title: data['title'] ?? 'Chat Conversation',
          summary: data['summary'],
          totalMessages: data['total_messages'] ?? 0,
          startedAt: DateTime.parse(data['started_at']),
          lastMessageAt: DateTime.parse(data['last_message_at']),
          status: data['status'],
        );
      }).toList();
    } catch (e) {
      _logger.e('Failed to get conversations: $e');
      return [];
    }
  }

  /// Archive a conversation
  Future<void> archiveConversation(String conversationId) async {
    try {
      await _supabase
          .from('chat_conversations')
          .update({'status': 'archived'}).eq('id', conversationId);

      _logger.i('Archived conversation $conversationId');
    } catch (e) {
      _logger.e('Failed to archive conversation: $e');
      rethrow;
    }
  }

  /// Delete a conversation and its messages
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete messages first (due to foreign key constraint)
      await _supabase
          .from('chat_messages')
          .delete()
          .eq('conversation_id', conversationId);

      // Then delete conversation
      await _supabase
          .from('chat_conversations')
          .delete()
          .eq('id', conversationId);

      _logger.i('Deleted conversation $conversationId');
    } catch (e) {
      _logger.e('Failed to delete conversation: $e');
      rethrow;
    }
  }

  /// Update conversation title
  Future<void> updateConversationTitle(
      String conversationId, String title) async {
    try {
      await _supabase
          .from('chat_conversations')
          .update({'title': title}).eq('id', conversationId);

      _logger.d('Updated conversation title: $title');
    } catch (e) {
      _logger.e('Failed to update conversation title: $e');
      rethrow;
    }
  }

  /// Generate a conversation title based on first few messages
  Future<String> generateConversationTitle(String conversationId) async {
    try {
      // Get first user message
      final response = await _supabase
          .from('chat_messages')
          .select('message')
          .eq('conversation_id', conversationId)
          .eq('sender_type', 'user')
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        String firstMessage = response['message'];
        // Truncate and clean up for title
        if (firstMessage.length > 50) {
          firstMessage = '${firstMessage.substring(0, 47)}...';
        }
        return firstMessage;
      }

      return 'Chat with CardSense AI';
    } catch (e) {
      _logger.e('Failed to generate conversation title: $e');
      return 'Chat with CardSense AI';
    }
  }

  /// Clear all conversations for current user (for testing/reset)
  Future<void> clearAllConversations() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Delete all messages first
      await _supabase.from('chat_messages').delete().eq('user_id', user.id);

      // Then delete conversations
      await _supabase
          .from('chat_conversations')
          .delete()
          .eq('user_id', user.id);

      _logger.i('Cleared all conversations for user');
    } catch (e) {
      _logger.e('Failed to clear conversations: $e');
      rethrow;
    }
  }
}

// Data models
class ChatConversation {
  final String id;
  final String title;
  final String? summary;
  final int totalMessages;
  final DateTime startedAt;
  final DateTime lastMessageAt;
  final String status;

  ChatConversation({
    required this.id,
    required this.title,
    this.summary,
    required this.totalMessages,
    required this.startedAt,
    required this.lastMessageAt,
    required this.status,
  });

  @override
  String toString() =>
      'ChatConversation(id: $id, title: $title, messages: $totalMessages)';
}

// Enhanced chat messages notifier with persistence
class PersistentChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final ChatPersistenceService _persistenceService;
  final EnhancedChatService _chatService;
  String? _currentConversationId;
  final Logger _logger = Logger();

  PersistentChatMessagesNotifier(this._persistenceService, this._chatService)
      : super([]) {
    _initializeConversation();
  }

  /// Initialize conversation and load history
  Future<void> _initializeConversation() async {
    try {
      // Ensure user profile exists first
      final profileService = ProfileService();
      await profileService.ensureUserProfile();

      _currentConversationId =
          await _persistenceService.getCurrentConversationId();
      final history = await _persistenceService.loadConversationHistory(
        conversationId: _currentConversationId,
      );

      if (history.isEmpty) {
        // Add welcome message if no history
        state = [
          ChatMessage.assistant(
            "Hi! I'm CardSense AI, your specialized assistant for Indian credit cards and related financial topics. I can help you with card comparisons, rewards optimization, and credit-related questions. What would you like to know about credit cards?",
          ),
        ];
      } else {
        state = history;
      }

      _logger.i(
          'Initialized conversation ${_currentConversationId} with ${state.length} messages');
    } catch (e) {
      _logger.e('Failed to initialize conversation: $e');
      // Fallback to default state
      state = [
        ChatMessage.assistant(
          "Hi! I'm CardSense AI, your specialized assistant for Indian credit cards and related financial topics. I can help you with card comparisons, rewards optimization, and credit-related questions. What would you like to know about credit cards?",
        ),
      ];
    }
  }

  /// Add user message and save to database
  Future<void> addUserMessage(String message) async {
    final userMessage = ChatMessage.user(message);
    state = [...state, userMessage];

    try {
      await _persistenceService.saveMessage(
        message: message,
        isUser: true,
        conversationId: _currentConversationId,
      );
    } catch (e) {
      _logger.e('Failed to save user message: $e');
      // Message still appears in UI, but not persisted
    }
  }

  /// Add assistant message and save to database
  Future<void> addAssistantMessage(String message, {String? model}) async {
    final assistantMessage = ChatMessage.assistant(message, model: model);
    state = [...state, assistantMessage];

    try {
      await _persistenceService.saveMessage(
        message: message,
        isUser: false,
        conversationId: _currentConversationId,
        aiModel: model,
      );
    } catch (e) {
      _logger.e('Failed to save assistant message: $e');
      // Message still appears in UI, but not persisted
    }
  }

  /// Send message with AI response and persistence
  Future<void> sendMessage(String message) async {
    // Add user message
    await addUserMessage(message);

    // Add typing indicator
    addTypingIndicator();

    try {
      final startTime = DateTime.now();

      // Get AI response
      final response = await _chatService.sendMessage(
        message: message,
        conversationHistory:
            state.where((msg) => msg.message != "...").toList(),
        model: 'rag-enhanced', // Use RAG model for better credit card responses
      );

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      // Remove typing indicator and add response
      removeTypingIndicator();
      await addAssistantMessage(response, model: 'openai/gpt-4o-mini');

      // Update conversation title if this is one of the first messages
      if (state.length <= 4) {
        _updateConversationTitle();
      }
    } catch (e) {
      removeTypingIndicator();
      await addAssistantMessage(
        "Sorry, I'm having trouble connecting right now. Please check your internet connection and try again.",
      );
      _logger.e('Failed to get AI response: $e');
    }
  }

  /// Update conversation title based on first message
  void _updateConversationTitle() async {
    if (_currentConversationId != null) {
      try {
        final title = await _persistenceService
            .generateConversationTitle(_currentConversationId!);
        await _persistenceService.updateConversationTitle(
            _currentConversationId!, title);
      } catch (e) {
        _logger.e('Failed to update conversation title: $e');
      }
    }
  }

  void addTypingIndicator() {
    state = [...state, ChatMessage.assistant("...")];
  }

  void removeTypingIndicator() {
    if (state.isNotEmpty && state.last.message == "...") {
      state = state.sublist(0, state.length - 1);
    }
  }

  void updateLastMessage(String content, {String? model}) {
    if (state.isNotEmpty && !state.last.isUser) {
      final updatedMessage =
          state.last.copyWith(message: content, model: model);
      state = [...state.sublist(0, state.length - 1), updatedMessage];
    }
  }

  /// Start a new conversation
  Future<void> startNewConversation() async {
    try {
      // Archive current conversation if it has messages
      if (_currentConversationId != null && state.length > 1) {
        await _persistenceService.archiveConversation(_currentConversationId!);
      }

      // Reset state and initialize new conversation
      _currentConversationId = null;
      await _initializeConversation();
    } catch (e) {
      _logger.e('Failed to start new conversation: $e');
    }
  }

  /// Clear all messages (for logout or reset)
  Future<void> clearMessages() async {
    try {
      await _persistenceService.clearAllConversations();
      await _initializeConversation();
    } catch (e) {
      _logger.e('Failed to clear messages: $e');
      // Fallback to local clear
      state = [
        ChatMessage.assistant(
          "Hi! I'm CardSense AI, your specialized assistant for Indian credit cards and related financial topics. I can help you with card comparisons, rewards optimization, and credit-related questions. What would you like to know about credit cards?",
        ),
      ];
    }
  }

  /// Reload conversation history
  Future<void> reloadConversation() async {
    await _initializeConversation();
  }

  String? get currentConversationId => _currentConversationId;
}

// Riverpod providers
final chatPersistenceServiceProvider = Provider<ChatPersistenceService>((ref) {
  return ChatPersistenceService();
});

final persistentChatMessagesProvider =
    StateNotifierProvider<PersistentChatMessagesNotifier, List<ChatMessage>>(
        (ref) {
  final persistenceService = ref.read(chatPersistenceServiceProvider);
  final chatService = ref.read(enhancedChatServiceProvider);
  return PersistentChatMessagesNotifier(persistenceService, chatService);
});

final chatConversationsProvider = FutureProvider<List<ChatConversation>>((ref) {
  final persistenceService = ref.read(chatPersistenceServiceProvider);
  return persistenceService.getConversations();
});
