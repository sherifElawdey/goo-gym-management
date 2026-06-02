import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';

/// Handles FCM setup without blocking app startup.
/// On iOS Simulator, APNS is unavailable — token fetch is skipped safely.
class NotificationService {
  NotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<void> initialize() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (!kIsWeb && Platform.isIOS) {
        await _initializeIosMessaging();
        return;
      }

      await _logFcmToken();
    } catch (error, stackTrace) {
      AppLogger.error('NotificationService.initialize', error, stackTrace: stackTrace);
    }
  }

  Future<void> _initializeIosMessaging() async {
    final apnsToken = await _waitForApnsToken(
      maxAttempts: 8,
      delay: const Duration(milliseconds: 500),
    );

    if (apnsToken == null) {
      if (kDebugMode) {
        debugPrint(
          'NotificationService: APNS token not available (common on iOS Simulator). '
          'Push notifications disabled; app continues normally.',
        );
      }
      // Token may arrive later on a physical device after registration.
      _messaging.onTokenRefresh.listen((token) {
        if (kDebugMode) {
          debugPrint('FCM token (refresh): $token');
        }
      });
      return;
    }

    await _logFcmToken();
  }

  Future<String?> _waitForApnsToken({
    required int maxAttempts,
    required Duration delay,
  }) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final token = await _messaging.getAPNSToken();
        if (token != null) {
          return token;
        }
      } on FirebaseException catch (e) {
        if (e.code != 'apns-token-not-set') {
          rethrow;
        }
      }
      await Future<void>.delayed(delay);
    }
    return null;
  }

  Future<void> _logFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('FCM token: $token');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'apns-token-not-set') {
        if (kDebugMode) {
          debugPrint('NotificationService: FCM token deferred until APNS is ready.');
        }
        return;
      }
      rethrow;
    }
  }
}
