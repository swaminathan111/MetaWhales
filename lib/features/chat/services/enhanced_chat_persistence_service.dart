import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'openrouter_service.dart';
import 'rag_chat_service.dart';
import '../../auth/services/profile_service.dart';

/// Enhanced chat persistence service with rolling window and context management
class EnhancedChatPersistenceService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();
  
  // Configuration constants
  static const int maxTurnsPerSession = 30; // 20-30 turns as requested
  static const int maxTokensPerSession = 10000; // ~8-10k tokens
  static const int hardCapTurns = 200; // Hard cap before auto-splitting
  static const int rollingWindowSize = 20; // Last N turns to send to model

  /// Get or create current active conversation for user with turn management
  Future<String> getCurrentConversationId() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final profileService = ProfileService();
      await profileService.ensureUserProfile();

      // Check for existing active conversation
      final response = await _supabase
          .from('chat_conversations')
          .select('id, total_messages')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .order('last_message_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final totalMessages = response['total_messages'] ?? 0;
        
        // Check if we need to start a new conversation due to hard cap
        if (totalMessages >= hardCapTurns) {
          _logger.i('Hard cap reached ($totalMessages messages), creating new conversation');
          await _archiveConversation(response['id']);
          return await _createNewConversation();
        }
        
        return response['id'] as String;
      }

      return await _createNewConversation();
    } catch (e) {
      _logger.e('Failed to get conversation ID: $e');
      rethrow;
    }
  }

  /// Create a new conversation
  Future<String> _createNewConversation() async {
    final user = _supabase.auth.currentUser!;
    
    final newConversation = await _supabase
        .from('chat_conversations')
        .insert({
          'user_id': user.id,
          'title': 'Chat with CardSense AI',
          'status': 'active',
          'total_messages': 0,
        })
        .select('id')
        .single();

    _logger.i('Created new conversation: ${newConversation['id']}');
    return newConversation['id'] as String;
  }

  /// Archive a conversation
  Future<void> _archiveConversation(String conversationId) async {
    await _supabase
        .from('chat_conversations')
        .update({'status': 'archived'})
        .eq('id', conversationId);
  }

  /// Load conversation history with rolling window optimization
  Future<List<ChatMessage>> loadConversationHistory({
    String? conversationId,
    int? limit,
    bool useRollingWindow = true,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final currentConversationId =
          conversationId ?? await getCurrentConversationId();

      // Use rolling window for context management
      final effectiveLimit = useRollingWindow 
          ? rollingWindowSize 
          : (limit ?? maxTurnsPerSession);

      final response = await _supabase
          .from('chat_messages')
          .select('*')
          .eq('conversation_id', currentConversationId)
          .order('created_at', ascending: false)
          .limit(effectiveLimit);

      final messages = response.reversed.map<ChatMessage>((messageData) {
        return ChatMessage(
          isUser: messageData['sender_type'] == 'user',
          message: messageData['message'],
          timestamp: DateTime.parse(messageData['created_at']),
          model: messageData['ai_model_used'],
        );
      }).toList();

      _logger.i('Loaded ${messages.length} messages from conversation $currentConversationId (rolling window: $useRollingWindow)');
      return messages;
    } catch (e) {
      _logger.e('Failed to load conversation history: $e');
      return [];
    }
  }

  /// Get conversation context for AI model (rolling window + summary)
  Future<List<ChatMessage>> getContextForModel(String conversationId) async {
    try {
      // Get recent messages (rolling window)
      final recentMessages = await loadConversationHistory(
        conversationId: conversationId,
        useRollingWindow: true,
      );

      // If we have fewer than rolling window size, return all
      if (recentMessages.length <= rollingWindowSize) {
        return recentMessages;
      }

      // Get conversation summary if available
      final summaryResponse = await _supabase
          .from('chat_conversations')
          .select('summary')
          .eq('id', conversationId)
          .single();

      final summary = summaryResponse['summary'] as String?;
      
      // Combine summary with recent messages
      final contextMessages = <ChatMessage>[];
      
      if (summary != null && summary.isNotEmpty) {
        contextMessages.add(ChatMessage.assistant(
          "Previous conversation summary: $summary",
        ));
      }
      
      contextMessages.addAll(recentMessages);
      
      return contextMessages;
    } catch (e) {
      _logger.e('Failed to get context for model: $e');
      // Fallback to recent messages only
      return await loadConversationHistory(
        conversationId: conversationId,
        useRollingWindow: true,
      );
    }
  }

  /// Save a message to the database with turn counting
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

      // Update conversation metadata
      await _supabase.from('chat_conversations').update({
        'last_message_at': DateTime.now().toIso8601String(),
        'total_messages': await _getMessageCount(currentConversationId),
      }).eq('id', currentConversationId);

      _logger.d('Saved message to conversation $currentConversationId');
    } catch (e) {
      _logger.e('Failed to save message: $e');
      rethrow;
    }
  }

  /// Get total message count for a conversation
  Future<int> _getMessageCount(String conversationId) async {
    final response = await _supabase
        .from('chat_messages')
        .select('id')
        .eq('conversation_id', conversationId)
        .count();
    
    return response.count;
  }

  /// Generate and save conversation summary
  Future<void> generateConversationSummary(String conversationId) async {
    try {
      // Get all messages for summary generation
      final allMessages = await loadConversationHistory(
        conversationId: conversationId,
        useRollingWindow: false,
      );

      if (allMessages.length < 6) return; // Don't summarize short conversations

      // Create summary from conversation
      final conversationText = allMessages
          .map((msg) => '${msg.isUser ? "User" : "Assistant"}: ${msg.message}')
          .join('\n');

      // Simple extractive summary (first user message + key topics)
      final firstUserMessage = allMessages.firstWhere((msg) => msg.isUser).message;
      final summary = 'Started with: "$firstUserMessage". ${allMessages.length} total messages about credit cards and financial advice.';

      // Save summary
      await _supabase
          .from('chat_conversations')
          .update({'summary': summary})
          .eq('id', conversationId);

      _logger.i('Generated summary for conversation $conversationId');
    } catch (e) {
      _logger.e('Failed to generate conversation summary: $e');
    }
  }

  /// Clear all conversations for current user
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

  /// Check if conversation needs summarization
  Future<bool> needsSummarization(String conversationId) async {
    try {
      final response = await _supabase
          .from('chat_conversations')
          .select('total_messages, summary')
          .eq('id', conversationId)
          .single();

      final totalMessages = response['total_messages'] ?? 0;
      final hasSummary = response['summary'] != null;

      // Generate summary every 50 messages or if no summary exists after 20 messages
      return (totalMessages >= 50 && totalMessages % 50 == 0) || 
             (!hasSummary && totalMessages >= 20);
    } catch (e) {
      _logger.e('Failed to check summarization need: $e');
      return false;
    }
  }
}

/// Enhanced chat messages notifier with rolling window and context management
class EnhancedChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final EnhancedChatPersistenceService _persistenceService;
  final EnhancedChatService _chatService;
  String? _currentConversationId;
  final Logger _logger = Logger();

  EnhancedChatMessagesNotifier(this._persistenceService, this._chatService)
      : super([]) {
    _initializeConversation();
  }

  /// Initialize conversation and load history
  Future<void> _initializeConversation() async {
    try {
      final profileService = ProfileService();
      await profileService.ensureUserProfile();

      _currentConversationId =
          await _persistenceService.getCurrentConversationId();
      final history = await _persistenceService.loadConversationHistory(
        conversationId: _currentConversationId,
      );

      if (history.isEmpty) {
        state = [
          ChatMessage.assistant(
            "Hi! I'm CardSense AI, your personalized assistant for Indian credit cards. I can help you with card recommendations, benefit optimization, and spending strategies. What would you like to know?",
          ),
        ];
      } else {
        state = history;
      }

      _logger.i('Initialized conversation ${_currentConversationId} with ${state.length} messages');
    } catch (e) {
      _logger.e('Failed to initialize conversation: $e');
      state = [
        ChatMessage.assistant(
          "Hi! I'm CardSense AI, your personalized assistant for Indian credit cards. I can help you with card recommendations, benefit optimization, and spending strategies. What would you like to know?",
        ),
      ];
    }
  }

  /// Send message with enhanced context management
  Future<void> sendMessage(String message) async {
    // Add user message
    await addUserMessage(message);

    // Add typing indicator
    addTypingIndicator();

    try {
      final startTime = DateTime.now();

      // Get context for AI model (rolling window + summary)
      final contextMessages = await _persistenceService.getContextForModel(_currentConversationId!);

      // Get AI response
      final response = await _chatService.sendMessage(
        message: message,
        conversationHistory: contextMessages.where((msg) => msg.message != "...").toList(),
        model: 'rag-enhanced',
      );

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      // Remove typing indicator and add response
      removeTypingIndicator();
      await addAssistantMessage(response, model: 'openai/gpt-4o-mini');

      // Check if we need to generate summary
      if (await _persistenceService.needsSummarization(_currentConversationId!)) {
        await _persistenceService.generateConversationSummary(_currentConversationId!);
      }

    } catch (e) {
      removeTypingIndicator();
      await addAssistantMessage(
        "Sorry, I'm having trouble connecting right now. Please check your internet connection and try again.",
      );
      _logger.e('Failed to get AI response: $e');
    }
  }

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
    }
  }

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

  /// Clear all messages
  Future<void> clearMessages() async {
    try {
      await _persistenceService.clearAllConversations();
      await _initializeConversation();
    } catch (e) {
      _logger.e('Failed to clear messages: $e');
      state = [
        ChatMessage.assistant(
          "Hi! I'm CardSense AI, your personalized assistant for Indian credit cards. I can help you with card recommendations, benefit optimization, and spending strategies. What would you like to know?",
        ),
      ];
    }
  }

  String? get currentConversationId => _currentConversationId;
}

// Enhanced providers
final enhancedChatPersistenceServiceProvider = Provider<EnhancedChatPersistenceService>((ref) {
  return EnhancedChatPersistenceService();
});

final enhancedChatMessagesProvider =
    StateNotifierProvider<EnhancedChatMessagesNotifier, List<ChatMessage>>((ref) {
  final persistenceService = ref.read(enhancedChatPersistenceServiceProvider);
  final chatService = ref.read(enhancedChatServiceProvider);
  return EnhancedChatMessagesNotifier(persistenceService, chatService);
});
