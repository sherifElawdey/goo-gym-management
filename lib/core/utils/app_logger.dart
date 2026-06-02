import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Prints errors to the debug console with context and stack traces.
class AppLogger {
  static void error(
    String context,
    Object error, {
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer()
      ..writeln('══════════ ERROR [$context] ══════════')
      ..writeln(_formatError(error));

    if (stackTrace != null) {
      buffer.writeln('Stack trace:');
      buffer.writeln(stackTrace);
    }

    buffer.writeln('════════════════════════════════════════');

    debugPrint(buffer.toString());
  }

  static String _formatError(Object error) {
    if (error is FirebaseException) {
      return 'FirebaseException\n'
          '  plugin: ${error.plugin}\n'
          '  code: ${error.code}\n'
          '  message: ${error.message}\n'
          '  stackTrace: ${error.stackTrace}';
    }
    if (error is FirebaseAuthException) {
      return 'FirebaseAuthException\n'
          '  code: ${error.code}\n'
          '  message: ${error.message}';
    }
    return error.toString();
  }

  static String userMessage(Object error) {
    if (error is FirebaseException) {
      return '[${error.code}] ${error.message ?? error.toString()}';
    }
    if (error is FirebaseAuthException) {
      return '[${error.code}] ${error.message ?? error.toString()}';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
