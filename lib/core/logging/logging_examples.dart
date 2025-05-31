// This file contains examples of how to use the logging system
// You can remove this file once you're familiar with the logging patterns

import 'app_logger.dart';
import 'performance_monitor.dart';
import 'api_logger.dart';

class LoggingExamples {
  // Example 1: Basic logging with different levels
  static void basicLoggingExample() {
    // Use for detailed debugging information (only in debug builds)
    AppLogger.debug('User tapped login button', null, null,
        {'screen': 'login', 'timestamp': DateTime.now().toIso8601String()});

    // Use for general information
    AppLogger.info('User session started', null, null,
        {'userId': '12345', 'sessionId': 'abc-def-ghi'});

    // Use for potential issues that aren't errors
    AppLogger.warning('API rate limit approaching', null, null,
        {'requests_remaining': 5, 'reset_time': '2024-01-01T12:00:00Z'});

    // Use for errors that should be addressed
    AppLogger.error(
        'Failed to save user preferences',
        Exception('Network error'),
        null,
        {'userId': '12345', 'feature': 'preferences'});
  }

  // Example 2: Feature-specific logging
  static void featureSpecificLoggingExample() {
    // Authentication events
    AppLogger.auth('User login attempt', null, null,
        {'method': 'google', 'timestamp': DateTime.now().toIso8601String()});

    // UI events
    AppLogger.ui('Screen transition', null, null,
        {'from': 'home', 'to': 'profile', 'animation': 'slide_right'});

    // Navigation events
    AppLogger.navigation('Route changed', null, null, {
      'route': '/profile',
      'params': {'userId': '12345'}
    });

    // API calls
    AppLogger.api('Making API request', null, null,
        {'endpoint': '/api/user/profile', 'method': 'GET'});
  }

  // Example 3: Performance monitoring
  static Future<void> performanceMonitoringExample() async {
    // Time an async operation
    final result = await PerformanceMonitor.timeAsync(
        'load_user_profile', () => _loadUserProfile(), {'userId': '12345'});

    // Time a sync operation
    final processedData = PerformanceMonitor.timeSync('process_user_data',
        () => _processUserData(result), {'dataSize': result.length});

    // Manual timing
    PerformanceMonitor.startTimer('custom_operation');
    await Future.delayed(Duration(milliseconds: 500));
    PerformanceMonitor.stopTimer('custom_operation', {'custom_param': 'value'});
  }

  // Example 4: API logging
  static Future<void> apiLoggingExample() async {
    final url = 'https://api.example.com/users/12345';
    final headers = {'Authorization': 'Bearer token123'};

    // Log the request
    ApiLogger.logRequest(
      method: 'GET',
      url: url,
      headers: headers,
    );

    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 200));

      // Log successful response
      ApiLogger.logResponse(
        method: 'GET',
        url: url,
        statusCode: 200,
        body: {'user': 'data'},
        duration: Duration(milliseconds: 200),
      );

      // Log performance
      ApiLogger.logPerformance(
        method: 'GET',
        url: url,
        duration: Duration(milliseconds: 200),
        statusCode: 200,
        responseSize: 1024,
      );
    } catch (error, stackTrace) {
      // Log API error
      ApiLogger.logError(
        method: 'GET',
        url: url,
        error: error,
        stackTrace: stackTrace,
        duration: Duration(milliseconds: 200),
      );
    }
  }

  // Example 5: Error handling with context
  static void errorHandlingExample() {
    try {
      throw Exception('Something went wrong');
    } catch (error, stackTrace) {
      AppLogger.error('Critical operation failed', error, stackTrace, {
        'operation': 'save_user_data',
        'userId': '12345',
        'timestamp': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'platform': 'android',
      });
    }
  }

  // Mock methods for examples
  static Future<String> _loadUserProfile() async {
    await Future.delayed(Duration(milliseconds: 300));
    return 'user_profile_data';
  }

  static String _processUserData(String data) {
    return data.toUpperCase();
  }
}

// Example usage in a real screen
class ExampleScreen {
  void onScreenInit() {
    AppLogger.info('Screen initialized', null, null, {
      'screen': 'example_screen',
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  void onButtonPressed(String buttonId) {
    AppLogger.ui('Button pressed', null, null,
        {'button_id': buttonId, 'screen': 'example_screen'});
  }

  Future<void> loadData() async {
    await PerformanceMonitor.timeAsync('load_screen_data', () async {
      AppLogger.debug('Starting data load');

      // Simulate data loading
      await Future.delayed(Duration(milliseconds: 500));

      AppLogger.debug('Data load completed');
    }, {'screen': 'example_screen'});
  }

  void onError(dynamic error, StackTrace stackTrace) {
    AppLogger.error('Screen error occurred', error, stackTrace,
        {'screen': 'example_screen', 'user_action': 'load_data'});
  }
}
