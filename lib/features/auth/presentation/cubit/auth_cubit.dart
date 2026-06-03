import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/constants/auth_messages.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required GymRepository repository,
    required SharedPreferences prefs,
  })  : _repository = repository,
        _prefs = prefs,
        super(AuthInitialState());

  final GymRepository _repository;
  final SharedPreferences _prefs;
  StreamSubscription<bool>? _subscription;

  Future<void> checkSession() async {
    emit(AuthLoadingState());
    _subscription?.cancel();
    _subscription = _repository.authChanges().listen(
      (isAuth) => unawaited(_syncRoleState(isAuth)),
      onError: (error, stackTrace) {
        AppLogger.error('authChanges', error, stackTrace: stackTrace);
        emit(AuthErrorState(message: AppLogger.userMessage(error)));
        emit(UnauthenticatedState());
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    emit(AuthLoadingState());
    try {
      await _repository.signIn(email: email, password: password);
      await _prefs.setBool('remember_me', rememberMe);
      await _resolvePostLoginState();
    } catch (e, stackTrace) {
      AppLogger.error('AuthCubit.login', e, stackTrace: stackTrace);
      emit(AuthErrorState(message: _friendlyMessage(e)));
      emit(UnauthenticatedState());
    }
  }

  Future<void> claimInitialAdmin() async {
    emit(AuthLoadingState());
    try {
      await _repository.claimInitialAdmin();
      final role = await _repository.currentUserRole();
      if (role == null) {
        emit(AuthErrorState(message: AuthMessages.adminNotCreated));
        emit(UnauthenticatedState());
        return;
      }
      emit(AuthenticatedState(role: role));
    } catch (e, stackTrace) {
      AppLogger.error('AuthCubit.claimInitialAdmin', e, stackTrace: stackTrace);
      emit(AuthErrorState(message: _friendlyMessage(e)));
      emit(NeedsBootstrapState(email: FirebaseAuth.instance.currentUser?.email ?? ''));
    }
  }

  Future<void> _resolvePostLoginState() async {
    try {
      final role = await _repository.currentUserRole();
      if (role != null) {
        emit(AuthenticatedState(role: role));
        return;
      }

      final bootstrapped = await _repository.isGymBootstrapped();
      if (!bootstrapped) {
        emit(NeedsBootstrapState(email: FirebaseAuth.instance.currentUser?.email ?? ''));
        return;
      }

      emit(AuthErrorState(message: AuthMessages.notInAdmins));
      await _repository.signOut();
      emit(UnauthenticatedState());
    } catch (e, stackTrace) {
      AppLogger.error('AuthCubit._resolvePostLoginState', e, stackTrace: stackTrace);
      emit(AuthErrorState(message: _friendlyMessage(e)));
      await _repository.signOut();
      emit(UnauthenticatedState());
    }
  }

  Future<void> _syncRoleState(bool isAuth) async {
    if (!isAuth) {
      emit(UnauthenticatedState());
      return;
    }
    await _resolvePostLoginState();
  }

  Future<void> logout() async {
    await _repository.signOut();
    emit(UnauthenticatedState());
  }

  Future<void> reauthenticateWithPassword(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (email == null) {
      throw Exception(AuthMessages.noAdminRole);
    }
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user!.reauthenticateWithCredential(credential);
  }

  String _friendlyMessage(Object error) => AuthMessages.fromError(error);

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
