import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'openrouter_service.dart';
import '../../../services/env_service.dart';
import '../../../services/user_context_service.dart';

class RagChatService {
  final Logger _logger = Logger();
  final UserContextService _userContextService = UserContextService();

  /// Send message to RAG API with conversation history and user context
  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> conversationHistory,
    String? model,
  }) async {
    try {
      _logger.d(
          'Sending personalized message to RAG API: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');

      final baseUrl = EnvService.selectedRagApiBaseUrl;

      _logger.d('Using RAG API: $baseUrl');

      // 🔍 DEBUG: Log conversation history being sent
      _logger.i('Conversation history length: ${conversationHistory.length}');

      // 🔧 OPTIMIZATION: Only use last 5 messages for context efficiency
      final recentHistory = conversationHistory.length > 5
          ? conversationHistory.sublist(conversationHistory.length - 5)
          : conversationHistory;

      _logger.i(
          'Using last ${recentHistory.length} messages for RAG context (limited from ${conversationHistory.length})');

      for (int i = 0; i < recentHistory.length; i++) {
        final msg = recentHistory[i];
        _logger.d(
            'RecentHistory[$i]: ${msg.isUser ? 'USER' : 'ASSISTANT'}: ${msg.message.substring(0, msg.message.length > 50 ? 50 : msg.message.length)}...');
      }

      // Get user context for personalization
      final userContext = await _userContextService.getUserContext();

      // Convert ChatMessage to simple format for user context
      final conversationData = recentHistory
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.message,
                'timestamp': msg.timestamp.toIso8601String(),
              })
          .toList();

      // 🔍 ENHANCED DEBUG: Log the conversation data being passed
      _logger.i('🔍 ENHANCED DEBUG: conversationData before formatting:');
      for (int i = 0; i < conversationData.length; i++) {
        _logger.i('  [$i]: ${conversationData[i]}');
      }
      _logger.i('🔍 conversationData.length: ${conversationData.length}');
      _logger.i('🔍 conversationData.isEmpty: ${conversationData.isEmpty}');

      _logger.i(
          'Retrieved user context for personalized response: ${userContext.hasCards ? 'Has cards' : 'No cards'}, Context complete: ${userContext.hasCompleteContext}, Cards count: ${userContext.ownedCards.length}, Conversation history: ${recentHistory.length} messages');

      // Format context to INCLUDE conversation history
      final ragFormattedContext = _userContextService
          .formatCompleteContextForRAG(userContext, conversationData);

      // 🐛 DEBUG: Check if conversation_history is included in ragFormattedContext
      _logger.i(
          '🔍 DEBUG: ragFormattedContext keys: ${ragFormattedContext.keys.toList()}');
      if (ragFormattedContext.containsKey('conversation_history')) {
        final convHistory =
            ragFormattedContext['conversation_history'] as List<dynamic>?;
        _logger.i(
            '✅ CONVERSATION HISTORY FOUND in user_context: ${convHistory?.length ?? 0} messages');

        // Log first and last messages for verification
        if (convHistory != null && convHistory.isNotEmpty) {
          _logger.i('📝 First message: ${convHistory.first}');
          if (convHistory.length > 1) {
            _logger.i('📝 Last message: ${convHistory.last}');
          }
        } else {
          _logger.e('❌ CONVERSATION HISTORY IS EMPTY!');
        }
      } else {
        _logger.e('❌ CONVERSATION HISTORY NOT FOUND in user_context!');
      }

      // 🔍 ENHANCED DEBUG: Log the formatted context before sending
      _logger.i('🔍 FORMATTED USER CONTEXT:');
      _logger.i(
          '🔍 ragFormattedContext keys: ${ragFormattedContext.keys.toList()}');
      if (ragFormattedContext.containsKey('conversation_history')) {
        _logger.i(
            '✅ CONVERSATION HISTORY FOUND in user_context: ${ragFormattedContext['conversation_history']?.length ?? 0} messages');
      } else {
        _logger.e('❌ CONVERSATION HISTORY MISSING from user_context');
      }

      // 🔍 NEW: Print the complete user_context for debugging
      _logger.i('🔍 COMPLETE USER_CONTEXT BEING SENT:');
      try {
        final userContextJson = jsonEncode(ragFormattedContext);
        _logger.i('📋 user_context JSON: $userContextJson');
      } catch (e) {
        _logger.e('❌ Failed to encode user_context to JSON: $e');
        _logger.i('📋 user_context (raw): $ragFormattedContext');
      }

      // 🔍 ENHANCED DEBUG: Log the full ragFormattedContext structure
      _logger.i('🔍 FULL ragFormattedContext structure:');
      final contextJson = json.encode(ragFormattedContext);
      final maxContextLength =
          contextJson.length > 1000 ? 1000 : contextJson.length;
      _logger.i(
          '${contextJson.substring(0, maxContextLength)}${contextJson.length > 1000 ? '...' : ''}');

      // Prepare request body
      final requestBody = {
        'question': message,
        'user_context': ragFormattedContext,
      };

      final requestJson = json.encode(requestBody);
      final maxLength = requestJson.length > 500 ? 500 : requestJson.length;
      _logger.d(
          'RAG API request with user context: ${requestJson.substring(0, maxLength)}...');

      final response = await http
          .post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Accept',
        },
        body: json.encode(requestBody),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception(
              'RAG API request timeout (60s) - please check your internet connection');
        },
      );

      _logger.d('RAG API response status: ${response.statusCode}');
      _logger.d('RAG API response body: ${response.body}');

      if (response.statusCode == 200) {
        late final dynamic decodedResponse;

        try {
          decodedResponse = json.decode(response.body);
        } catch (e) {
          _logger.e('Failed to decode JSON response: $e');
          _logger.e('Response body: ${response.body}');
          throw Exception('RAG API returned invalid JSON response: $e');
        }

        // Handle the new API response format
        String content;
        if (decodedResponse is Map<String, dynamic>) {
          final responseData = decodedResponse as Map<String, dynamic>;

          // New API format: {response_text: "..."}
          content = responseData['response_text'] ??
              responseData['content'] ??
              responseData['message'] ??
              responseData['response'] ??
              responseData['text'] ??
              responseData.toString();
        } else if (decodedResponse is String) {
          content = decodedResponse;
        } else {
          content = decodedResponse.toString();
        }

        if (content.isEmpty) {
          throw Exception('Empty response from RAG API');
        }

        _logger.i(
            'Received RAG response: ${content.length > 100 ? content.substring(0, 100) : content}...');
        return content;
      } else {
        _logger.e('RAG API error: ${response.statusCode} - ${response.body}');
        throw Exception('RAG API request failed: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Failed to get RAG response: $e');

      // Provide more specific error messages based on error type
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('ClientException')) {
        throw Exception('RAG API connection failed. This could be due to:\n'
            '• CORS configuration issues on the server\n'
            '• Network connectivity problems\n'
            '• The API endpoint might be down\n'
            'Original error: $e');
      } else if (e.toString().contains('timeout')) {
        throw Exception(
            'RAG API request timed out. Please check your internet connection and try again.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception(
            'RAG API returned invalid JSON response. The server might be experiencing issues.');
      } else {
        throw Exception('RAG API error: $e');
      }
    }
  }

  /// Send message with streaming response (if supported by RAG API)
  Stream<String> sendMessageStream({
    required String message,
    required List<ChatMessage> conversationHistory,
    String? model,
  }) async* {
    try {
      _logger.d('Starting streaming request to RAG API');

      final baseUrl = EnvService.selectedRagApiBaseUrl;

      // Note: New API might not support streaming, so we'll fall back to regular request
      _logger.w(
          'RAG API may not support streaming, falling back to regular request');
      try {
        final response = await sendMessage(
          message: message,
          conversationHistory: conversationHistory,
          model: model,
        );
        yield response;
        return;
      } catch (e) {
        _logger.e('Failed to get response from RAG API: $e');
        yield 'Sorry, I encountered an error while processing your request. Please try again.';
        return;
      }
    } catch (e) {
      _logger.e('Failed to stream RAG response: $e');
      yield 'Sorry, I encountered an error while processing your request. Please try again.';
    }
  }

  /// Test RAG API connectivity
  Future<bool> testConnection() async {
    try {
      final testMessage = 'Hello, this is a connection test.';
      final response = await sendMessage(
        message: testMessage,
        conversationHistory: [],
      );
      return response.isNotEmpty;
    } catch (e) {
      _logger.e('RAG API connection test failed: $e');
      return false;
    }
  }

  /// Detailed connectivity test with diagnostic information
  Future<Map<String, dynamic>> testConnectionDetailed() async {
    final baseUrl = EnvService.selectedRagApiBaseUrl;

    final result = <String, dynamic>{
      'success': false,
      'response_time_ms': 0,
      'error': null,
      'endpoint': baseUrl,
      'cors_test': false,
      'network_test': false,
    };

    final stopwatch = Stopwatch()..start();

    try {
      // First, try a simple network test
      result['network_test'] = await _testNetworkConnectivity();

      // Test actual RAG API call with user context
      final userContext = await _userContextService.getUserContext();
      final ragFormattedContext =
          _userContextService.formatContextForRAG(userContext);

      Map<String, dynamic> testPayload;

      testPayload = {
        'question': 'Connection test',
        'user_context': ragFormattedContext,
      };

      _logger.d('Testing RAG API with payload: ${json.encode(testPayload)}');

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(testPayload),
          )
          .timeout(const Duration(seconds: 60));

      stopwatch.stop();
      result['response_time_ms'] = stopwatch.elapsedMilliseconds;
      result['cors_test'] = true; // If we got here, CORS is working

      _logger.d('RAG test response status: ${response.statusCode}');
      _logger.d('RAG test response headers: ${response.headers}');
      _logger.d('RAG test response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('response_text')) {
            result['success'] = true;
            result['sample_response'] = responseData['response_text'];
          } else {
            result['error'] = 'Response format unexpected: ${response.body}';
          }
        } else {
          result['error'] = 'Response format unexpected: ${response.body}';
        }
      } else {
        result['error'] = 'HTTP ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      stopwatch.stop();
      result['response_time_ms'] = stopwatch.elapsedMilliseconds;
      result['error'] = e.toString();

      if (e.toString().contains('Failed to fetch')) {
        result['cors_test'] = false;
        result['error'] =
            'CORS error detected. The RAG API server needs to allow cross-origin requests.';
      }

      _logger.e('Detailed RAG connection test failed: $e');
    }

    return result;
  }

  /// Test basic network connectivity
  Future<bool> _testNetworkConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'),
          headers: {
            'User-Agent': 'CardSense-AI-Test'
          }).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get RAG API health status
  Future<Map<String, dynamic>> getHealthStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${EnvService.selectedRagApiBaseUrl}/health'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'code': response.statusCode,
          'message': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }
}

// Enhanced chat service that combines RAG and fallback
class EnhancedChatService {
  final RagChatService _ragService;
  final OpenRouterService _fallbackService;
  final Logger _logger = Logger();

  EnhancedChatService(this._ragService, this._fallbackService);

  /// Send message with RAG API as primary and OpenRouter as fallback
  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> conversationHistory,
    String? model,
  }) async {
    try {
      // Try RAG API first for better credit card knowledge
      _logger.d('Attempting RAG API for message: $message');
      final ragResponse = await _ragService.sendMessage(
        message: message,
        conversationHistory: conversationHistory,
        model: model,
      );

      _logger.i('Successfully got RAG response');
      return ragResponse;
    } catch (e) {
      _logger.w('RAG API failed, falling back to OpenRouter: $e');

      try {
        // Fallback to OpenRouter if RAG fails
        final fallbackResponse = await _fallbackService.sendMessage(
          message: message,
          conversationHistory: conversationHistory,
        );

        // Add a note that this is from fallback service
        return '$fallbackResponse\n\n_Note: This response is from our backup AI service. For the most accurate credit card information, please try again later._';
      } catch (fallbackError) {
        _logger.e('Both RAG and fallback services failed: $fallbackError');
        throw Exception(
            'Unable to get AI response. Please check your connection and try again.');
      }
    }
  }

  /// Send message with streaming (prioritize RAG, fallback to OpenRouter)
  Stream<String> sendMessageStream({
    required String message,
    required List<ChatMessage> conversationHistory,
    String? model,
  }) async* {
    try {
      _logger.d('Attempting RAG streaming for message: $message');

      // Try RAG streaming first
      bool hasYieldedContent = false;
      await for (final chunk in _ragService.sendMessageStream(
        message: message,
        conversationHistory: conversationHistory,
        model: model,
      )) {
        hasYieldedContent = true;
        yield chunk;
      }

      if (!hasYieldedContent) {
        throw Exception('No content received from RAG streaming');
      }
    } catch (e) {
      _logger.w('RAG streaming failed, falling back to OpenRouter: $e');

      try {
        // Fallback to OpenRouter (non-streaming)
        yield '\n\n_Switching to backup AI service..._\n\n';

        final fallbackResponse = await _fallbackService.sendMessage(
          message: message,
          conversationHistory: conversationHistory,
        );

        yield fallbackResponse;
        yield '\n\n_Note: This response is from our backup AI service._';
      } catch (fallbackError) {
        _logger.e('Both RAG and fallback streaming failed: $fallbackError');
        yield 'Sorry, I\'m having trouble connecting right now. Please check your internet connection and try again.';
      }
    }
  }

  /// Check which services are available
  Future<Map<String, bool>> checkServiceAvailability() async {
    final results = <String, bool>{};

    // Test RAG API
    try {
      results['rag'] = await _ragService.testConnection();
    } catch (e) {
      results['rag'] = false;
    }

    // Test OpenRouter (assuming it has a test method or we can try a simple call)
    try {
      await _fallbackService.sendMessage(
        message: 'test',
        conversationHistory: [],
      );
      results['openrouter'] = true;
    } catch (e) {
      results['openrouter'] = false;
    }

    return results;
  }
}

// Riverpod providers
final userContextServiceProvider = Provider<UserContextService>((ref) {
  return UserContextService();
});

final ragChatServiceProvider = Provider<RagChatService>((ref) {
  return RagChatService();
});

final enhancedChatServiceProvider = Provider<EnhancedChatService>((ref) {
  final ragService = ref.read(ragChatServiceProvider);
  final fallbackService = ref.read(openRouterServiceProvider);
  return EnhancedChatService(ragService, fallbackService);
});

// Provider to check service availability
final chatServiceAvailabilityProvider =
    FutureProvider<Map<String, bool>>((ref) {
  final enhancedService = ref.read(enhancedChatServiceProvider);
  return enhancedService.checkServiceAvailability();
});

// Provider for user context
final userContextProvider = FutureProvider<UserContext>((ref) {
  final contextService = ref.read(userContextServiceProvider);
  return contextService.getUserContext();
});
