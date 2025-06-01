import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../../services/prompt_service.dart';

class OpenRouterService {
  final Logger _logger = Logger();
  late final String _apiKey;
  late final String _baseUrl;
  late final String _appName;
  late final String _appUrl;

  OpenRouterService() {
    _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    // Use direct API for all platforms (temporary fix for CORS)
    _baseUrl =
        dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1';
    _appName = dotenv.env['APP_NAME'] ?? 'CardSense AI';
    _appUrl = dotenv.env['APP_URL'] ?? 'https://cardsense.ai';

    if (_apiKey.isEmpty) {
      throw Exception('OpenRouter API key not found in environment variables');
    }

    _logger.i('OpenRouterService initialized with CORS-friendly HTTP client');
  }

  /// Clear the cached system prompt to force reload of updated prompt
  void clearPromptCache() {
    PromptService.clearCache();
    _logger.i(
        'Prompt cache cleared - new system prompt will be loaded on next request');
  }

  /// Send a message and get AI response - CORS compatible
  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> conversationHistory,
    String? model,
  }) async {
    try {
      final selectedModel =
          model ?? dotenv.env['DEFAULT_AI_MODEL'] ?? 'openai/gpt-4o-mini';

      // Build messages array
      final messages = <Map<String, dynamic>>[];

      // Load system prompt from file
      final systemPrompt = await PromptService.getSystemPrompt();

      // Add system message
      messages.add({
        'role': 'system',
        'content': systemPrompt,
      });

      // Add conversation history
      for (final msg in conversationHistory) {
        messages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.message,
        });
      }

      // Add current message
      messages.add({
        'role': 'user',
        'content': message,
      });

      final requestBody = {
        'model': selectedModel,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 500,
      };

      final requestUrl = '$_baseUrl/chat/completions';
      _logger.d('Sending request to OpenRouter: $selectedModel');
      _logger.d('Request URL: $requestUrl');
      _logger.d('API Key (first 10 chars): ${_apiKey.substring(0, 10)}...');

      final response = await http.post(
        Uri.parse(requestUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': _appUrl,
          'X-Title': _appName,
          // No openai-beta header that causes CORS issues
        },
        body: json.encode(requestBody),
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response headers: ${response.headers}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final content = responseData['choices']?[0]?['message']?['content'] ??
            'Sorry, I couldn\'t generate a response.';

        _logger.d(
            'Received response from OpenRouter: ${content.length > 50 ? content.substring(0, 50) : content}...');
        return content;
      } else {
        _logger.e(
            'OpenRouter API error: ${response.statusCode} - ${response.body}');
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Failed to get AI response: $e');
      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Get available models from OpenRouter
  Future<List<AIModel>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': _appUrl,
          'X-Title': _appName,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final models = responseData['data'] as List;

        return models
            .map((model) => AIModel(
                  id: model['id'],
                  name: model['id']
                      .split('/')
                      .last
                      .replaceAll('-', ' ')
                      .toUpperCase(),
                  provider: model['id'].split('/').first,
                ))
            .toList();
      } else {
        _logger.w('Failed to fetch models: ${response.statusCode}');
        return _getDefaultModels();
      }
    } catch (e) {
      _logger.w('Failed to fetch models, returning defaults: $e');
      return _getDefaultModels();
    }
  }

  List<AIModel> _getDefaultModels() {
    return [
      AIModel(
          id: 'openai/gpt-4o-mini', name: 'GPT-4O Mini', provider: 'OpenAI'),
      AIModel(id: 'openai/gpt-4o', name: 'GPT-4O', provider: 'OpenAI'),
      AIModel(
          id: 'anthropic/claude-3-haiku',
          name: 'Claude 3 Haiku',
          provider: 'Anthropic'),
      AIModel(
          id: 'anthropic/claude-3-sonnet',
          name: 'Claude 3 Sonnet',
          provider: 'Anthropic'),
      AIModel(
          id: 'meta-llama/llama-3.1-8b-instruct:free',
          name: 'Llama 3.1 8B (Free)',
          provider: 'Meta'),
      AIModel(id: 'google/gemini-pro', name: 'Gemini Pro', provider: 'Google'),
    ];
  }

  /// Get cost-effective free models
  Future<List<AIModel>> getFreeModels() async {
    final allModels = await getAvailableModels();
    return allModels.where((model) => model.id.contains(':free')).toList();
  }

  void dispose() {
    _logger.i('OpenRouterService disposed');
  }
}

// Data models
class ChatMessage {
  final bool isUser;
  final String message;
  final DateTime timestamp;
  final String? model;

  ChatMessage({
    required this.isUser,
    required this.message,
    DateTime? timestamp,
    this.model,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.user(String message) {
    return ChatMessage(isUser: true, message: message);
  }

  factory ChatMessage.assistant(String message, {String? model}) {
    return ChatMessage(isUser: false, message: message, model: model);
  }

  ChatMessage copyWith({
    bool? isUser,
    String? message,
    DateTime? timestamp,
    String? model,
  }) {
    return ChatMessage(
      isUser: isUser ?? this.isUser,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      model: model ?? this.model,
    );
  }
}

class AIModel {
  final String id;
  final String name;
  final String provider;

  AIModel({
    required this.id,
    required this.name,
    required this.provider,
  });

  @override
  String toString() => '$provider: $name';
}

// Riverpod providers
final openRouterServiceProvider = Provider<OpenRouterService>((ref) {
  return OpenRouterService();
});

final corsCompatibleChatMessagesProvider = StateNotifierProvider<
    CorsCompatibleChatMessagesNotifier, List<ChatMessage>>((ref) {
  return CorsCompatibleChatMessagesNotifier();
});

class CorsCompatibleChatMessagesNotifier
    extends StateNotifier<List<ChatMessage>> {
  CorsCompatibleChatMessagesNotifier()
      : super([
          ChatMessage.assistant(
              "Hi! I'm CardSense AI, your specialized assistant for Indian credit cards and related financial topics. I can help you with card comparisons, rewards optimization, and credit-related questions. What would you like to know about credit cards?"),
        ]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
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

  void clearMessages() {
    state = [
      ChatMessage.assistant(
          "Hi! I'm CardSense AI, your specialized assistant for Indian credit cards and related financial topics. I can help you with card comparisons, rewards optimization, and credit-related questions. What would you like to know about credit cards?"),
    ];
  }
}
