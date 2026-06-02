import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';

void setupGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    AppLogger.error(
      'FlutterError',
      details.exception,
      stackTrace: details.stack,
    );
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('PlatformDispatcher', error, stackTrace: stack);
    return true;
  };
}

/// Runs [body] inside a zone that logs uncaught async errors.
Future<void> runAppWithErrorLogging(Future<void> Function() body) async {
  await runZonedGuarded(
    body,
    (error, stack) {
      AppLogger.error('Uncaught async', error, stackTrace: stack);
    },
  );
}

void showErrorSnackBar(BuildContext context, Object error) {
  final message = AppLogger.userMessage(error);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 6),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
