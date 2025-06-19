import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'openrouter_service.dart';
import '../../../services/env_service.dart';

class RagChatService {
  final Logger _logger = Logger();

  /// Send message to RAG API with conversation history
  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> conversationHistory,
    String? model,
  }) async {
    try {
      _logger.d(
          'Sending message to RAG API: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');

      final baseUrl = EnvService.selectedRagApiBaseUrl;
      final isNewApi = EnvService.useNewRagApi;

      _logger.d('Using RAG API: $baseUrl (${isNewApi ? 'new' : 'old'} format)');

      // Prepare request body based on API version
      Map<String, dynamic> requestBody;

      if (isNewApi) {
        // New API format: simple question field
        requestBody = {
          'question': message,
        };
      } else {
        // Old API format: messages array with conversation history
        final messages = <Map<String, dynamic>>[];

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

        requestBody = {
          'messages': messages,
          'stream': false,
        };
      }

      _logger.d('RAG API request: ${json.encode(requestBody)}');

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

        // Handle the response format based on API version
        String content;
        if (decodedResponse is Map<String, dynamic>) {
          final responseData = decodedResponse as Map<String, dynamic>;

          if (isNewApi) {
            // New API format: {response_text: "..."}
            content = responseData['response_text'] ?? responseData.toString();
          } else {
            // Old API format: {answer: "...", sources: [...]}
            if (responseData.containsKey('answer')) {
              content = responseData['answer'] as String;

              // Optionally include source information for old API
              if (responseData.containsKey('sources') &&
                  responseData['sources'] is List &&
                  (responseData['sources'] as List).isNotEmpty) {
                content += '\n\n📚 Sources:';
                final sources = responseData['sources'] as List;
                for (int i = 0; i < sources.length && i < 3; i++) {
                  final source = sources[i];
                  if (source is Map<String, dynamic> &&
                      source.containsKey('content')) {
                    final sourceContent = source['content'] as String;
                    final shortContent = sourceContent.length > 100
                        ? '${sourceContent.substring(0, 100)}...'
                        : sourceContent;
                    content += '\n• $shortContent';

                    if (source.containsKey('url') && source['url'] != null) {
                      content += '\n  🔗 ${source['url']}';
                    }
                  }
                }
              }
            } else {
              // Fallback to other possible response fields
              content = responseData['content'] ??
                  responseData['message'] ??
                  responseData['response'] ??
                  responseData['text'] ??
                  responseData.toString();
            }
          }
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
      final isNewApi = EnvService.useNewRagApi;

      // Note: New API might not support streaming, so we'll fall back to regular request
      if (isNewApi) {
        _logger.w(
            'New RAG API may not support streaming, falling back to regular request');
        try {
          final response = await sendMessage(
            message: message,
            conversationHistory: conversationHistory,
            model: model,
          );
          yield response;
          return;
        } catch (e) {
          _logger.e('Failed to get response from new API: $e');
          yield 'Sorry, I encountered an error while processing your request. Please try again.';
          return;
        }
      }

      // Old API streaming logic
      final messages = <Map<String, dynamic>>[];

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
        'messages': messages,
        'stream': true, // Enable streaming
      };

      final request = http.Request('POST', Uri.parse(baseUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/plain',
      });
      request.body = json.encode(requestBody);

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        await for (final chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          if (chunk.isNotEmpty) {
            // Handle Server-Sent Events format if used
            if (chunk.startsWith('data: ')) {
              final data = chunk.substring(6).trim();
              if (data != '[DONE]' && data.isNotEmpty) {
                try {
                  final jsonData = json.decode(data);
                  final content =
                      jsonData['content'] ?? jsonData['delta'] ?? data;
                  if (content.isNotEmpty) {
                    yield content;
                  }
                } catch (e) {
                  // If not JSON, yield as plain text
                  yield data;
                }
              }
            } else {
              // Plain text chunk
              yield chunk;
            }
          }
        }
      } else {
        throw Exception(
            'Streaming request failed: ${streamedResponse.statusCode}');
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
    final isNewApi = EnvService.useNewRagApi;

    final result = <String, dynamic>{
      'success': false,
      'response_time_ms': 0,
      'error': null,
      'endpoint': baseUrl,
      'api_version': isNewApi ? 'new' : 'old',
      'cors_test': false,
      'network_test': false,
    };

    final stopwatch = Stopwatch()..start();

    try {
      // First, try a simple network test
      result['network_test'] = await _testNetworkConnectivity();

      // Test actual RAG API call with appropriate format
      Map<String, dynamic> testPayload;

      if (isNewApi) {
        testPayload = {'question': 'Connection test'};
      } else {
        testPayload = {
          'messages': [
            {'role': 'user', 'content': 'Connection test'}
          ]
        };
      }

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
          if (isNewApi && responseData.containsKey('response_text')) {
            result['success'] = true;
            result['sample_response'] = responseData['response_text'];
          } else if (!isNewApi && responseData.containsKey('answer')) {
            result['success'] = true;
            result['sample_response'] = responseData['answer'];
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
