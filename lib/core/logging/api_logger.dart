import 'dart:convert';
import 'app_logger.dart';

class ApiLogger {
  /// Log an outgoing HTTP request
  static void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) {
    final context = {
      'method': method,
      'url': url,
      'has_body': body != null,
      'has_headers': headers?.isNotEmpty ?? false,
      'query_params': queryParameters?.keys.toList(),
    };

    AppLogger.api('HTTP Request: $method $url', null, null, context);

    if (headers != null && headers.isNotEmpty) {
      AppLogger.debug('Request headers', null, null, {
        'headers': _sanitizeHeaders(headers),
      });
    }

    if (body != null) {
      AppLogger.debug('Request body', null, null, {
        'body_type': body.runtimeType.toString(),
        'body_preview': _sanitizeBody(body),
      });
    }
  }

  /// Log an incoming HTTP response
  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    Map<String, String>? headers,
    dynamic body,
    Duration? duration,
  }) {
    final context = {
      'method': method,
      'url': url,
      'status_code': statusCode,
      'success': statusCode >= 200 && statusCode < 300,
      'duration_ms': duration?.inMilliseconds,
    };

    final logLevel = statusCode >= 400 ? 'error' : 'success';
    final message = 'HTTP Response: $statusCode $method $url';

    if (statusCode >= 400) {
      AppLogger.error(message, null, null, context);
    } else {
      AppLogger.api(message, null, null, context);
    }

    if (headers != null && headers.isNotEmpty) {
      AppLogger.debug('Response headers', null, null, {
        'headers': _sanitizeHeaders(headers),
      });
    }

    if (body != null) {
      AppLogger.debug('Response body', null, null, {
        'body_type': body.runtimeType.toString(),
        'body_preview': _sanitizeBody(body),
      });
    }
  }

  /// Log an API error
  static void logError({
    required String method,
    required String url,
    required dynamic error,
    StackTrace? stackTrace,
    Duration? duration,
  }) {
    final context = {
      'method': method,
      'url': url,
      'error_type': error.runtimeType.toString(),
      'duration_ms': duration?.inMilliseconds,
    };

    AppLogger.error('HTTP Error: $method $url', error, stackTrace, context);
  }

  /// Log API performance metrics
  static void logPerformance({
    required String method,
    required String url,
    required Duration duration,
    required int statusCode,
    int? responseSize,
  }) {
    final context = {
      'method': method,
      'url': url,
      'duration_ms': duration.inMilliseconds,
      'status_code': statusCode,
      'response_size_bytes': responseSize,
    };

    if (duration.inMilliseconds > 5000) {
      AppLogger.warning('Slow API call detected', null, null, context);
    } else {
      AppLogger.performance('API performance', null, null, context);
    }
  }

  /// Sanitize headers to remove sensitive information
  static Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);

    // List of headers that should be masked
    const sensitiveHeaders = [
      'authorization',
      'cookie',
      'x-api-key',
      'x-auth-token',
      'api-key',
    ];

    for (final header in sensitiveHeaders) {
      if (sanitized.containsKey(header.toLowerCase())) {
        sanitized[header] = '***MASKED***';
      }
    }

    return sanitized;
  }

  /// Sanitize body content to prevent logging sensitive data
  static String _sanitizeBody(dynamic body) {
    try {
      if (body is String) {
        // Try to parse as JSON and sanitize
        try {
          final json = jsonDecode(body);
          return _sanitizeJsonObject(json).toString();
        } catch (e) {
          // If not JSON, just truncate the string
          return body.length > 500 ? '${body.substring(0, 500)}...' : body;
        }
      } else if (body is Map) {
        return _sanitizeJsonObject(body).toString();
      } else {
        return body.toString();
      }
    } catch (e) {
      return 'Error sanitizing body: $e';
    }
  }

  /// Sanitize JSON object by masking sensitive fields
  static Map<String, dynamic> _sanitizeJsonObject(dynamic json) {
    if (json is Map<String, dynamic>) {
      final sanitized = <String, dynamic>{};

      // List of fields that should be masked
      const sensitiveFields = [
        'password',
        'token',
        'secret',
        'key',
        'authorization',
        'auth',
        'credential',
        'private',
      ];

      for (final entry in json.entries) {
        final key = entry.key.toLowerCase();
        final shouldMask = sensitiveFields.any((field) => key.contains(field));

        if (shouldMask) {
          sanitized[entry.key] = '***MASKED***';
        } else if (entry.value is Map<String, dynamic>) {
          sanitized[entry.key] = _sanitizeJsonObject(entry.value);
        } else if (entry.value is List) {
          sanitized[entry.key] = (entry.value as List)
              .map((item) => item is Map<String, dynamic>
                  ? _sanitizeJsonObject(item)
                  : item)
              .toList();
        } else {
          sanitized[entry.key] = entry.value;
        }
      }

      return sanitized;
    }

    return json;
  }
}
