# Logging System Documentation

## Overview

The CardSense AI app uses a comprehensive logging system with multiple levels and features for better debugging and traceability. The logging system is environment-aware and supports both console and file output.

## Log Levels

### Available Levels (in order of severity):

1. **VERBOSE** - Extremely detailed information (rarely used)
2. **DEBUG** - Detailed debugging information for development
3. **INFO** - General information about app flow
4. **WARNING** - Potential issues that aren't errors
5. **ERROR** - Errors that should be addressed
6. **WTF** - Critical errors that should never happen

### Environment Configuration

#### Development (`.env.dev`):
- **LOG_LEVEL**: `DEBUG` - Shows all logs except VERBOSE
- **LOG_TO_CONSOLE**: `true` - Logs appear in console
- **LOG_TO_FILE**: `true` - Logs saved to file

#### Production (`.env.prod`):
- **LOG_LEVEL**: `ERROR` - Only shows errors and critical issues
- **LOG_TO_CONSOLE**: `false` - No console output
- **LOG_TO_FILE**: `true` - Errors saved to file for debugging

## Basic Usage

### Standard Logging

```dart
import 'package:cardsense_ai/core/logging/app_logger.dart';

// Debug information (development only)
AppLogger.debug('User tapped login button', null, null, {
  'screen': 'login',
  'timestamp': DateTime.now().toIso8601String()
});

// General information
AppLogger.info('User session started', null, null, {
  'userId': '12345',
  'sessionId': 'abc-def-ghi'
});

// Warnings
AppLogger.warning('API rate limit approaching', null, null, {
  'requests_remaining': 5,
  'reset_time': '2024-01-01T12:00:00Z'
});

// Errors
AppLogger.error('Failed to save user preferences', error, stackTrace, {
  'userId': '12345',
  'feature': 'preferences'
});
```

### Feature-Specific Logging

```dart
// Authentication events
AppLogger.auth('User login attempt', null, null, {
  'method': 'google',
  'timestamp': DateTime.now().toIso8601String()
});

// UI events
AppLogger.ui('Screen transition', null, null, {
  'from': 'home',
  'to': 'profile',
  'animation': 'slide_right'
});

// Navigation events
AppLogger.navigation('Route changed', null, null, {
  'route': '/profile',
  'params': {'userId': '12345'}
});

// API calls
AppLogger.api('Making API request', null, null, {
  'endpoint': '/api/user/profile',
  'method': 'GET'
});

// Performance monitoring
AppLogger.performance('Operation completed', null, null, {
  'operation': 'load_data',
  'duration_ms': 250
});
```

## Performance Monitoring

### Automatic Timing

```dart
import 'package:cardsense_ai/core/logging/performance_monitor.dart';

// Time an async operation
final result = await PerformanceMonitor.timeAsync(
  'load_user_profile',
  () => loadUserProfile(),
  {'userId': '12345'}
);

// Time a sync operation
final processedData = PerformanceMonitor.timeSync(
  'process_user_data',
  () => processUserData(result),
  {'dataSize': result.length}
);
```

### Manual Timing

```dart
// Start timing
PerformanceMonitor.startTimer('custom_operation');

// Your code here
await performOperation();

// Stop timing and log results
PerformanceMonitor.stopTimer('custom_operation', {
  'custom_param': 'value'
});
```

## API Logging

### HTTP Request/Response Logging

```dart
import 'package:cardsense_ai/core/logging/api_logger.dart';

// Log outgoing request
ApiLogger.logRequest(
  method: 'POST',
  url: 'https://api.example.com/users',
  headers: {'Authorization': 'Bearer token123'},
  body: {'name': 'John Doe'},
);

// Log incoming response
ApiLogger.logResponse(
  method: 'POST',
  url: 'https://api.example.com/users',
  statusCode: 201,
  body: {'id': '12345', 'name': 'John Doe'},
  duration: Duration(milliseconds: 250),
);

// Log API errors
ApiLogger.logError(
  method: 'POST',
  url: 'https://api.example.com/users',
  error: error,
  stackTrace: stackTrace,
  duration: Duration(milliseconds: 250),
);
```

## Best Practices

### 1. Use Appropriate Log Levels

- **DEBUG**: Use for detailed debugging information that helps during development
- **INFO**: Use for important application flow events
- **WARNING**: Use for recoverable issues that might need attention
- **ERROR**: Use for errors that affect functionality

### 2. Include Context

Always include relevant context information:

```dart
AppLogger.error('Database operation failed', error, stackTrace, {
  'operation': 'insert_user',
  'table': 'users',
  'userId': userId,
  'timestamp': DateTime.now().toIso8601String(),
  'app_version': '1.0.0',
});
```

### 3. Feature-Specific Logging

Use feature-specific methods for better categorization:

```dart
// Instead of
AppLogger.info('User authenticated');

// Use
AppLogger.auth('User authenticated', null, null, {
  'method': 'google',
  'userId': user.id
});
```

### 4. Performance Monitoring

Monitor critical operations:

```dart
// Monitor screen load times
await PerformanceMonitor.timeAsync(
  'load_profile_screen',
  () => loadProfileData(),
  {'userId': userId}
);

// Monitor API calls
await PerformanceMonitor.timeAsync(
  'api_get_user_profile',
  () => apiClient.getUserProfile(userId),
  {'userId': userId, 'endpoint': '/api/user/profile'}
);
```

### 5. Error Handling

Always include stack traces and context for errors:

```dart
try {
  await riskyOperation();
} catch (error, stackTrace) {
  AppLogger.error(
    'Risky operation failed',
    error,
    stackTrace,
    {
      'operation': 'risky_operation',
      'userId': currentUser?.id,
      'timestamp': DateTime.now().toIso8601String(),
    }
  );
  
  // Handle the error appropriately
  showErrorDialog();
}
```

## Log File Location

- **Android**: `/storage/emulated/0/Android/data/com.example.cardsense_ai/files/Documents/app_logs.txt`
- **iOS**: `Application Documents Directory/app_logs.txt`
- **Web**: Logs are only available in console (file logging not supported)

## Security Considerations

The logging system automatically sanitizes sensitive information:

- **Headers**: Authorization, API keys, tokens are masked
- **Body**: Passwords, secrets, private keys are masked
- **URLs**: Query parameters with sensitive names are masked

## Environment Switching

### Development
```bash
flutter run
# Uses .env.dev with DEBUG level logging
```

### Production
```bash
flutter run --dart-define=ENV=prod
# Uses .env.prod with ERROR level logging
```

## Troubleshooting

### Common Issues

1. **Logs not appearing**: Check if logger is initialized in `main.dart`
2. **File logging not working**: Ensure `path_provider` permissions are granted
3. **Too many logs**: Adjust `LOG_LEVEL` in environment file
4. **Performance impact**: Use appropriate log levels for production

### Debug Commands

```dart
// Check if logger is initialized
if (AppLogger._initialized) {
  print('Logger is ready');
}

// Get log file location
final logFile = AppLogger.logFile;
if (logFile != null) {
  print('Log file: ${logFile.path}');
}
```

## Integration Examples

### Screen Lifecycle

```dart
class ProfileScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    AppLogger.ui('Screen initialized', null, null, {
      'screen': 'profile',
      'userId': widget.userId
    });
  }

  @override
  void dispose() {
    AppLogger.ui('Screen disposed', null, null, {
      'screen': 'profile'
    });
    super.dispose();
  }
}
```

### API Service

```dart
class UserService {
  Future<User> getUser(String userId) async {
    return await PerformanceMonitor.timeAsync(
      'get_user_api',
      () async {
        ApiLogger.logRequest(
          method: 'GET',
          url: '/api/users/$userId',
        );

        try {
          final response = await httpClient.get('/api/users/$userId');
          
          ApiLogger.logResponse(
            method: 'GET',
            url: '/api/users/$userId',
            statusCode: response.statusCode,
            body: response.data,
          );

          return User.fromJson(response.data);
        } catch (error, stackTrace) {
          ApiLogger.logError(
            method: 'GET',
            url: '/api/users/$userId',
            error: error,
            stackTrace: stackTrace,
          );
          rethrow;
        }
      },
      {'userId': userId}
    );
  }
}
``` 