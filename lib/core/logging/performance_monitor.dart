import 'dart:async';
import 'app_logger.dart';

class PerformanceMonitor {
  static final Map<String, DateTime> _timers = {};

  /// Start timing an operation
  static void startTimer(String operation) {
    _timers[operation] = DateTime.now();
    AppLogger.performance('Timer started for: $operation');
  }

  /// Stop timing an operation and log the duration
  static void stopTimer(String operation, [Map<String, dynamic>? context]) {
    final startTime = _timers.remove(operation);
    if (startTime == null) {
      AppLogger.warning('Timer not found for operation: $operation');
      return;
    }

    final duration = DateTime.now().difference(startTime);
    final enrichedContext = {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'duration_readable': _formatDuration(duration),
      ...?context
    };

    if (duration.inMilliseconds > 1000) {
      AppLogger.warning(
          'Slow operation detected: $operation', null, null, enrichedContext);
    } else {
      AppLogger.performance(
          'Operation completed: $operation', null, null, enrichedContext);
    }
  }

  /// Time a future operation
  static Future<T> timeAsync<T>(
    String operation,
    Future<T> Function() future, [
    Map<String, dynamic>? context,
  ]) async {
    startTimer(operation);
    try {
      final result = await future();
      stopTimer(operation, context);
      return result;
    } catch (error, stackTrace) {
      stopTimer(operation, {...?context, 'error': true});
      AppLogger.error(
          'Timed operation failed: $operation', error, stackTrace, context);
      rethrow;
    }
  }

  /// Time a synchronous operation
  static T timeSync<T>(
    String operation,
    T Function() function, [
    Map<String, dynamic>? context,
  ]) {
    startTimer(operation);
    try {
      final result = function();
      stopTimer(operation, context);
      return result;
    } catch (error, stackTrace) {
      stopTimer(operation, {...?context, 'error': true});
      AppLogger.error(
          'Timed operation failed: $operation', error, stackTrace, context);
      rethrow;
    }
  }

  /// Log memory usage (if available)
  static void logMemoryUsage(String context) {
    try {
      // This is a simplified version - you might want to use more sophisticated memory monitoring
      AppLogger.performance('Memory check: $context', null, null, {
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.debug('Could not retrieve memory usage: $e');
    }
  }

  /// Log frame rendering performance
  static void logFramePerformance(Duration frameDuration) {
    final frameRate = 1000 / frameDuration.inMicroseconds * 1000;
    final context = {
      'frame_duration_ms': frameDuration.inMicroseconds / 1000,
      'estimated_fps': frameRate.round(),
    };

    if (frameDuration.inMilliseconds > 16) {
      // > 60 FPS
      AppLogger.warning('Frame drop detected', null, null, context);
    } else {
      AppLogger.debug('Frame rendered', null, null, context);
    }
  }

  static String _formatDuration(Duration duration) {
    if (duration.inSeconds > 0) {
      return '${duration.inSeconds}s ${duration.inMilliseconds % 1000}ms';
    } else {
      return '${duration.inMilliseconds}ms';
    }
  }
}
