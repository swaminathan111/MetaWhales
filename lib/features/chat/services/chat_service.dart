import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class ChatService {
  late final OpenAIClient _client;
  final Logger _logger = Logger();

  ChatService() {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    final baseUrl =
        dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1';
    final appName = dotenv.env['APP_NAME'] ?? 'CardSense AI';
    final appUrl = dotenv.env['APP_URL'] ?? 'https://cardsense.ai';

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenRouter API key not found in environment variables');
    }

    _client = OpenAIClient(
      apiKey: apiKey,
      baseUrl: baseUrl,
      headers: {
        'HTTP-Referer': appUrl, // Your app URL for OpenRouter rankings
        'X-Title': appName, // Your app name for OpenRouter rankings
      },
    );

    _logger.i('ChatService initialized with OpenRouter');
  }

  /// Send a message and get AI response
  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> conversationHistory,
    String? model,
  }) async {
    try {
      final selectedModel =
          model ?? dotenv.env['DEFAULT_AI_MODEL'] ?? 'openai/gpt-4o-mini';

      // Convert conversation history to OpenAI format
      final messages = [
        ChatCompletionMessage.system(
          content:
              '''You are a helpful AI assistant for CardSense, a premium credit card management app. 

Your expertise includes:
- Credit card recommendations and comparisons
- Rewards optimization and cashback strategies
- Credit score improvement tips
- Financial planning and budgeting advice
- Travel rewards and benefits guidance
- Security and fraud prevention

Guidelines:
- Be concise but informative (keep responses under 150 words)
- Provide actionable advice
- Use a friendly, professional tone
- If asked about specific financial products, provide general guidance but recommend consulting with financial advisors for personalized advice
- For card-specific questions, focus on general features and benefits rather than exact terms''',
        ),
        ...conversationHistory.map((msg) => msg.isUser
            ? ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(msg.message),
              )
            : ChatCompletionMessage.assistant(content: msg.message)),
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(message),
        ),
      ];

      _logger.d('Sending message to $selectedModel');

      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(selectedModel),
          messages: messages,
          temperature: 0.7,
          maxTokens: 500,
        ),
      );

      final content = response.choices.first.message.content ??
          'Sorry, I couldn\'t generate a response.';

      _logger.d('Received response from AI: ${content.substring(0, 50)}...');
      return content;
    } catch (e) {
      _logger.e('Failed to get AI response: $e');
      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Send message with streaming response for real-time chat experience
  Stream<String> sendMessageStream({
    required String message,
    required List<ChatMessage> conversationHistory,
    String? model,
  }) async* {
    try {
      final selectedModel =
          model ?? dotenv.env['DEFAULT_AI_MODEL'] ?? 'openai/gpt-4o-mini';

      final messages = [
        ChatCompletionMessage.system(
          content:
              '''You are a helpful AI assistant for CardSense, a premium credit card management app. 

Your expertise includes:
- Credit card recommendations and comparisons
- Rewards optimization and cashback strategies
- Credit score improvement tips
- Financial planning and budgeting advice
- Travel rewards and benefits guidance
- Security and fraud prevention

Guidelines:
- Be concise but informative (keep responses under 150 words)
- Provide actionable advice
- Use a friendly, professional tone
- If asked about specific financial products, provide general guidance but recommend consulting with financial advisors for personalized advice
- For card-specific questions, focus on general features and benefits rather than exact terms''',
        ),
        ...conversationHistory.map((msg) => msg.isUser
            ? ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(msg.message),
              )
            : ChatCompletionMessage.assistant(content: msg.message)),
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(message),
        ),
      ];

      _logger.d('Starting streaming response from $selectedModel');

      final stream = _client.createChatCompletionStream(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(selectedModel),
          messages: messages,
          temperature: 0.7,
          maxTokens: 500,
        ),
      );

      await for (final response in stream) {
        final content = response.choices.first.delta.content;
        if (content != null && content.isNotEmpty) {
          yield content;
        }
      }
    } catch (e) {
      _logger.e('Failed to stream AI response: $e');
      yield 'Sorry, I couldn\'t generate a response. Error: $e';
    }
  }

  /// Get available models from OpenRouter
  Future<List<AIModel>> getAvailableModels() async {
    try {
      final models = await _client.listModels();
      return models.data
          .map((model) => AIModel(
                id: model.id,
                name:
                    model.id.split('/').last.replaceAll('-', ' ').toUpperCase(),
                provider: model.id.split('/').first,
              ))
          .toList();
    } catch (e) {
      _logger.w('Failed to fetch models, returning defaults: $e');
      // Return some default popular models if API call fails
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
        AIModel(
            id: 'google/gemini-pro', name: 'Gemini Pro', provider: 'Google'),
      ];
    }
  }

  /// Get cost-effective free models
  Future<List<AIModel>> getFreeModels() async {
    final allModels = await getAvailableModels();
    return allModels.where((model) => model.id.contains(':free')).toList();
  }

  void dispose() {
    // OpenAI client doesn't need explicit disposal
    _logger.i('ChatService disposed');
  }
}

// Data models
class ChatMessage {
  final bool isUser;
  final String message;
  final DateTime timestamp;
  final String? model; // Track which model generated the response

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
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier();
});

final selectedModelProvider = StateProvider<String>((ref) {
  return dotenv.env['DEFAULT_AI_MODEL'] ?? 'openai/gpt-4o-mini';
});

final availableModelsProvider = FutureProvider<List<AIModel>>((ref) {
  final chatService = ref.read(chatServiceProvider);
  return chatService.getAvailableModels();
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier()
      : super([
          ChatMessage.assistant(
              "Hi! I'm here to help you with your credit cards and financial questions. What would you like to know?"),
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
          "Hi! I'm here to help you with your credit cards and financial questions. What would you like to know?"),
    ];
  }
}
