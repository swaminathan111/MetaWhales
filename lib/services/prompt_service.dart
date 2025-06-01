import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class PromptService {
  static final Logger _logger = Logger();
  static String? _cachedSystemPrompt;

  /// Load the CardSense system prompt from assets
  static Future<String> getSystemPrompt() async {
    if (_cachedSystemPrompt != null) {
      return _cachedSystemPrompt!;
    }

    try {
      _cachedSystemPrompt = await rootBundle.loadString(
        'lib/assets/prompts/cardsense_system_prompt.md',
      );
      _logger.d('System prompt loaded successfully from file');
      return _cachedSystemPrompt!;
    } catch (e) {
      _logger.e('Failed to load system prompt from file: $e');
      // Fallback to a basic prompt if file loading fails
      return _getFallbackPrompt();
    }
  }

  /// Clear cached prompt (useful for testing or hot reload)
  static void clearCache() {
    _cachedSystemPrompt = null;
    _logger.d('System prompt cache cleared');
  }

  /// Fallback prompt if file loading fails
  static String _getFallbackPrompt() {
    return '''You are CardSense AI, a helpful assistant for Indian credit card users.
    
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
- Focus on Indian credit cards only
- If asked about specific financial products, provide general guidance but recommend consulting with financial advisors for personalized advice''';
  }

  /// Load custom prompt from a different file (for testing or different variants)
  static Future<String> loadCustomPrompt(String assetPath) async {
    try {
      final prompt = await rootBundle.loadString(assetPath);
      _logger.d('Custom prompt loaded from $assetPath');
      return prompt;
    } catch (e) {
      _logger.e('Failed to load custom prompt from $assetPath: $e');
      throw Exception('Could not load prompt from $assetPath');
    }
  }

  /// Validate that the prompt contains required sections
  static bool validatePrompt(String prompt) {
    final requiredSections = [
      '# CardSense AI',
      'ROLE AND PERSONALITY',
      'OUTPUT FORMAT',
      'BEHAVIORAL CONSTRAINTS',
    ];

    for (final section in requiredSections) {
      if (!prompt.contains(section)) {
        _logger.w('Prompt validation failed: missing section "$section"');
        return false;
      }
    }

    _logger.d('Prompt validation passed');
    return true;
  }
}
