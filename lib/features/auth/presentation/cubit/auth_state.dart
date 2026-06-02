part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  AuthenticatedState({required this.role});

  final String role;

  @override
  List<Object?> get props => [role];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  AuthErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Firebase Auth succeeded but gym has no owner admin yet.
class NeedsBootstrapState extends AuthState {
  NeedsBootstrapState({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}
