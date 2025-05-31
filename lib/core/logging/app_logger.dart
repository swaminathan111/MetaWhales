import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';

enum LogLevel { verbose, debug, info, warning, error, wtf }

class AppLogger {
  static late Logger _logger;
  static late File? _logFile;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Get log level from environment
    final logLevelString = AppConfig.logLevel.toUpperCase();
    final logLevel = _parseLogLevel(logLevelString);

    // Configure logger output
    final outputs = <LogOutput>[];

    // Console output (if enabled)
    if (AppConfig.logToConsole) {
      outputs.add(ConsoleOutput());
    }

    // File output (if enabled)
    if (AppConfig.logToFile && !kIsWeb) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        _logFile = File('${directory.path}/app_logs.txt');
        outputs.add(FileOutput(file: _logFile!));
      } catch (e) {
        debugPrint('Failed to initialize file logging: $e');
      }
    }

    _logger = Logger(
      filter: _LogFilter(logLevel),
      printer: _AppLogPrinter(),
      output: MultiOutput(outputs),
    );

    _initialized = true;
    _logger.i(
        'Logger initialized - Level: $logLevelString, Environment: ${AppConfig.environment}');
  }

  // Log methods with context
  static void verbose(String message,
      [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _logWithContext(Level.trace, message, error, stackTrace, context);
  }

  static void debug(String message,
      [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _logWithContext(Level.debug, message, error, stackTrace, context);
  }

  static void info(String message,
      [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _logWithContext(Level.info, message, error, stackTrace, context);
  }

  static void warning(String message,
      [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _logWithContext(Level.warning, message, error, stackTrace, context);
  }

  static void error(String message,
      [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _logWithContext(Level.error, message, error, stackTrace, context);
  }

  static void wtf(String message,
      [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _logWithContext(Level.fatal, message, error, stackTrace, context);
  }

  // Feature-specific logging methods
  static void auth(String message,
      [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    final enrichedContext = {'feature': 'auth', ...?context};
    info('[AUTH] $message', error, stackTrace, enrichedContext);
  }

  static void api(String message,
      [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    final enrichedContext = {'feature': 'api', ...?context};
    debug('[API] $message', error, stackTrace, enrichedContext);
  }

  static void ui(String message,
      [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    final enrichedContext = {'feature': 'ui', ...?context};
    debug('[UI] $message', error, stackTrace, enrichedContext);
  }

  static void navigation(String message,
      [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    final enrichedContext = {'feature': 'navigation', ...?context};
    info('[NAV] $message', error, stackTrace, enrichedContext);
  }

  static void performance(String message,
      [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    final enrichedContext = {'feature': 'performance', ...?context};
    info('[PERF] $message', error, stackTrace, enrichedContext);
  }

  // Utility methods
  static void _logWithContext(Level level, String message, dynamic error,
      StackTrace? stackTrace, Map<String, dynamic>? context) {
    if (!_initialized) {
      debugPrint('Logger not initialized. Message: $message');
      return;
    }

    final enrichedMessage = context != null
        ? '$message | Context: ${_formatContext(context)}'
        : message;

    _logger.log(level, enrichedMessage, error: error, stackTrace: stackTrace);
  }

  static String _formatContext(Map<String, dynamic> context) {
    return context.entries.map((e) => '${e.key}=${e.value}').join(', ');
  }

  static Level _parseLogLevel(String levelString) {
    switch (levelString) {
      case 'VERBOSE':
        return Level.trace;
      case 'DEBUG':
        return Level.debug;
      case 'INFO':
        return Level.info;
      case 'WARNING':
        return Level.warning;
      case 'ERROR':
        return Level.error;
      case 'WTF':
        return Level.fatal;
      default:
        return Level.info;
    }
  }

  // Get log file for sharing/debugging
  static File? get logFile => _logFile;
}

class _LogFilter extends LogFilter {
  final Level minLevel;

  _LogFilter(this.minLevel);

  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= minLevel.index;
  }
}

class _AppLogPrinter extends LogPrinter {
  static const Map<Level, String> _levelEmojis = {
    Level.trace: '🔍',
    Level.debug: '🐛',
    Level.info: 'ℹ️',
    Level.warning: '⚠️',
    Level.error: '❌',
    Level.fatal: '💥',
  };

  @override
  List<String> log(LogEvent event) {
    final emoji = _levelEmojis[event.level] ?? '📝';
    final timestamp = DateTime.now().toIso8601String();

    return [
      '$emoji [$timestamp] [${event.level.name.toUpperCase()}] ${event.message}'
    ];
  }
}

class FileOutput extends LogOutput {
  final File file;

  FileOutput({required this.file});

  @override
  void output(OutputEvent event) {
    try {
      final logEntry = event.lines.join('\n') + '\n';
      file.writeAsStringSync(logEntry, mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to write to log file: $e');
    }
  }
}
