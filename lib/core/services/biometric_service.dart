import 'package:local_auth/local_auth.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';

class BiometricAuthResult {
  const BiometricAuthResult({
    required this.success,
    this.errorMessage,
  });

  final bool success;
  final String? errorMessage;
}

class BiometricService {
  BiometricService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e, stackTrace) {
      AppLogger.error('BiometricService.isDeviceSupported', e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      return await _auth.canCheckBiometrics;
    } catch (e, stackTrace) {
      AppLogger.error('BiometricService.isAvailable', e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> authenticate({required String reason}) async {
    final result = await authenticateWithDetails(reason: reason);
    return result.success;
  }

  Future<BiometricAuthResult> authenticateWithDetails({required String reason}) async {
    try {
      final success = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (success) {
        return const BiometricAuthResult(success: true);
      }
      return const BiometricAuthResult(
        success: false,
        errorMessage: 'cancelled',
      );
    } catch (e, stackTrace) {
      AppLogger.error('BiometricService.authenticate', e, stackTrace: stackTrace);
      return BiometricAuthResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
}
