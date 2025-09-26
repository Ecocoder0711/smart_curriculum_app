import 'dart:developer' as developer;

/// Application logger utility
/// Provides structured logging with different levels
class AppLogger {
  static const String _appName = 'SmartCurriculumApp';
  
  /// Log debug information
  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: _appName,
      level: 500, // Debug level
      time: DateTime.now(),
    );
  }
  
  /// Log general information
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: _appName,
      level: 800, // Info level
      time: DateTime.now(),
    );
  }
  
  /// Log warnings
  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: _appName,
      level: 900, // Warning level
      time: DateTime.now(),
    );
  }
  
  /// Log errors
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _appName,
      level: 1000, // Error level
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log for demo purposes (can be disabled in production)
  static void demo(String message, {String? feature}) {
    developer.log(
      '[DEMO] ${feature != null ? '[$feature] ' : ''}$message',
      name: _appName,
      level: 700, // Custom demo level
      time: DateTime.now(),
    );
  }
}