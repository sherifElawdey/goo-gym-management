part of 'dashboard_cubit.dart';

sealed class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitialState extends DashboardState {}

class DashboardLoadingState extends DashboardState {}

class DashboardLoadedState extends DashboardState {
  DashboardLoadedState({required this.stats});

  final DashboardStats stats;

  @override
  List<Object?> get props => [stats];
}

class DashboardErrorState extends DashboardState {
  DashboardErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
