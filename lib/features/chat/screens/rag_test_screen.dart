import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/rag_chat_service.dart';
import '../services/openrouter_service.dart';

class RagTestScreen extends ConsumerStatefulWidget {
  const RagTestScreen({super.key});

  @override
  ConsumerState<RagTestScreen> createState() => _RagTestScreenState();
}

class _RagTestScreenState extends ConsumerState<RagTestScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<TestMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addSystemMessage(
        'RAG API Integration Test\nTesting connectivity to: https://cardsense-ai.vercel.app/api/query');
  }

  void _addSystemMessage(String message) {
    setState(() {
      _messages.add(TestMessage(
        message: message,
        isUser: false,
        isSystem: true,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _addMessage(String message, bool isUser, {bool isError = false}) {
    setState(() {
      _messages.add(TestMessage(
        message: message,
        isUser: isUser,
        isError: isError,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _testRagConnection() async {
    _addMessage('🔍 Testing RAG API connection...', false);

    try {
      final ragService = ref.read(ragChatServiceProvider);

      // Run detailed connectivity test
      final diagnostics = await ragService.testConnectionDetailed();

      _addMessage('📊 Diagnostic Results:', false);
      _addMessage('• Endpoint: ${diagnostics['endpoint']}', false);
      _addMessage(
          '• Network Test: ${diagnostics['network_test'] ? "✅ Pass" : "❌ Fail"}',
          false);
      _addMessage(
          '• CORS Test: ${diagnostics['cors_test'] ? "✅ Pass" : "❌ Fail"}',
          false);
      _addMessage(
          '• Response Time: ${diagnostics['response_time_ms']}ms', false);

      if (diagnostics['success']) {
        _addMessage('✅ RAG API Connected Successfully!', false);
        _addMessage(
            'Sample Response: ${diagnostics['sample_response']}', false);
      } else {
        _addMessage('❌ RAG API Connection Failed', false, isError: true);
        _addMessage('Error: ${diagnostics['error']}', false, isError: true);

        // Provide troubleshooting suggestions
        if (!diagnostics['network_test']) {
          _addMessage('💡 Check your internet connection', false);
        } else if (!diagnostics['cors_test']) {
          _addMessage(
              '💡 CORS issue detected. Server needs to allow cross-origin requests.',
              false);
        }
      }
    } catch (e) {
      _addMessage('❌ Test Failed: $e', false, isError: true);
    }
  }

  Future<void> _testEnhancedService() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    _addMessage(message, true);

    setState(() => _isLoading = true);

    try {
      final enhancedService = ref.read(enhancedChatServiceProvider);

      // Convert test messages to ChatMessage format
      final history = _messages
          .where((msg) => !msg.isSystem && !msg.isError)
          .map((msg) => ChatMessage(
                isUser: msg.isUser,
                message: msg.message,
                timestamp: msg.timestamp,
              ))
          .toList();

      final response = await enhancedService.sendMessage(
        message: message,
        conversationHistory: history,
      );

      _addMessage(response, false);
    } catch (e) {
      _addMessage('Error: $e', false, isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testCreditCardQuery() async {
    // Test cases matching the Python script
    final testQueries = [
      'What are the benefits of the Pixel Play Card?',
      'Which card should I use for movie tickets?',
      'What are the best cashback credit cards in India?',
      'Which card gives the most rewards for online shopping?',
    ];

    for (final query in testQueries) {
      _addMessage('🧪 Testing: $query', true);

      try {
        final ragService = ref.read(ragChatServiceProvider);
        final response = await ragService.sendMessage(
          message: query,
          conversationHistory: [],
        );

        _addMessage('✅ RAG Response: $response', false);
      } catch (e) {
        _addMessage('❌ Failed: $e', false, isError: true);
      }

      // Add small delay between requests
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _testConversationContext() async {
    _addMessage(
        '🧪 Testing conversation context (like Python script)...', false);

    // First, simulate a conversation about a specific card
    final history = [
      ChatMessage(
        isUser: true,
        message:
            'Can you tell me about the features of the NovaSpark credit card?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      ChatMessage(
        isUser: false,
        message:
            'The NovaSpark card offers 2% cashback on all purchases and no annual fee.',
        timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
      ),
    ];

    try {
      final enhancedService = ref.read(enhancedChatServiceProvider);

      // Test context-dependent question
      final response = await enhancedService.sendMessage(
        message: 'Does it have any travel insurance benefits?',
        conversationHistory: history,
      );

      _addMessage('✅ Context Test Response: $response', false);

      // Test another context scenario
      final ambiguousHistory = [
        ChatMessage(
          isUser: true,
          message: "I'm looking at the Aurora Advantage card.",
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ];

      await Future.delayed(const Duration(milliseconds: 1000));

      final contextResponse = await enhancedService.sendMessage(
        message: 'What are its fees?',
        conversationHistory: ambiguousHistory,
      );

      _addMessage('✅ Ambiguous Context Test: $contextResponse', false);
    } catch (e) {
      _addMessage('❌ Context test failed: $e', false, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RAG API Test'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'test_connection':
                  await _testRagConnection();
                  break;
                case 'test_queries':
                  await _testCreditCardQuery();
                  break;
                case 'test_context':
                  await _testConversationContext();
                  break;
                case 'clear':
                  setState(() {
                    _messages.clear();
                    _addSystemMessage(
                        'RAG API Integration Test\nTesting connectivity to: https://cardsense-ai.vercel.app/api/query');
                  });
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'test_connection',
                child: Row(
                  children: [
                    Icon(Icons.wifi_find, size: 16),
                    SizedBox(width: 8),
                    Text('Test Connection'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test_queries',
                child: Row(
                  children: [
                    Icon(Icons.quiz, size: 16),
                    SizedBox(width: 8),
                    Text('Test Credit Card Queries'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test_context',
                child: Row(
                  children: [
                    Icon(Icons.chat, size: 16),
                    SizedBox(width: 8),
                    Text('Test Conversation Context'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear, size: 16),
                    SizedBox(width: 8),
                    Text('Clear'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Service Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Consumer(
              builder: (context, ref, child) {
                final serviceAvailability =
                    ref.watch(chatServiceAvailabilityProvider);
                return serviceAvailability.when(
                  data: (availability) {
                    final ragAvailable = availability['rag'] ?? false;
                    final fallbackAvailable =
                        availability['openrouter'] ?? false;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Status:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              ragAvailable ? Icons.check_circle : Icons.error,
                              size: 16,
                              color: ragAvailable ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                                'RAG API: ${ragAvailable ? 'Online' : 'Offline'}'),
                            const SizedBox(width: 24),
                            Icon(
                              fallbackAvailable
                                  ? Icons.check_circle
                                  : Icons.error,
                              size: 16,
                              color:
                                  fallbackAvailable ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                                'Fallback: ${fallbackAvailable ? 'Online' : 'Offline'}'),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const Text('Checking service status...'),
                  error: (error, stackTrace) =>
                      Text('Error checking status: $error'),
                );
              },
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _TestMessageBubble(message: message);
              },
            ),
          ),

          // Input
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Test RAG API with credit card questions...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _testEnhancedService(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _isLoading ? null : _testEnhancedService,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class TestMessage {
  final String message;
  final bool isUser;
  final bool isSystem;
  final bool isError;
  final DateTime timestamp;

  TestMessage({
    required this.message,
    required this.isUser,
    this.isSystem = false,
    this.isError = false,
    required this.timestamp,
  });
}

class _TestMessageBubble extends StatelessWidget {
  final TestMessage message;

  const _TestMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: message.isSystem
                  ? Colors.grey[300]
                  : message.isError
                      ? Colors.red[100]
                      : Colors.blue[100],
              child: Icon(
                message.isSystem
                    ? Icons.settings
                    : message.isError
                        ? Icons.error
                        : Icons.smart_toy,
                size: 18,
                color: message.isSystem
                    ? Colors.grey[600]
                    : message.isError
                        ? Colors.red[600]
                        : Colors.blue[600],
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.blue[500]
                    : message.isSystem
                        ? Colors.grey[100]
                        : message.isError
                            ? Colors.red[50]
                            : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: message.isError
                    ? Border.all(color: Colors.red[200]!)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white
                          : message.isError
                              ? Colors.red[800]
                              : Colors.black87,
                      fontSize: 14,
                      fontFamily: message.isSystem ? 'monospace' : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }
}
