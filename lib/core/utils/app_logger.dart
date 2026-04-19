import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void info(
    String feature,
    String method,
    String message, {
    String? payloadId,
  }) {
    debugPrint(_format('INFO', feature, method, message, payloadId: payloadId));
  }

  static void warning(
    String feature,
    String method,
    String message, {
    Object? error,
    String? payloadId,
  }) {
    debugPrint(
      _format(
        'WARN',
        feature,
        method,
        '$message${error == null ? '' : ' | error=$error'}',
        payloadId: payloadId,
      ),
    );
  }

  static void error(
    String feature,
    String method,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? payloadId,
  }) {
    debugPrint(
      _format(
        'ERROR',
        feature,
        method,
        '$message${error == null ? '' : ' | error=$error'}',
        payloadId: payloadId,
      ),
    );
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  static String _format(
    String level,
    String feature,
    String method,
    String message, {
    String? payloadId,
  }) {
    final id = payloadId == null || payloadId.isEmpty
        ? ''
        : ' [payload=$payloadId]';
    return '[YUSR][$level][$feature][$method]$id $message';
  }
}
