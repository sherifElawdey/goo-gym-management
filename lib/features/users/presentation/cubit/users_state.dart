part of 'users_cubit.dart';

sealed class UsersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsersInitialState extends UsersState {}

class UsersLoadingState extends UsersState {}

class UsersLoadedState extends UsersState {
  UsersLoadedState({
    required this.users,
    required this.query,
    required this.filter,
    this.genderFilter = 'all',
    this.subscriptionRangeStart,
    this.subscriptionRangeEnd,
  });

  final List<GymUser> users;
  final String query;
  final String filter;
  final String genderFilter;
  final DateTime? subscriptionRangeStart;
  final DateTime? subscriptionRangeEnd;

  @override
  List<Object?> get props =>
      [users, query, filter, genderFilter, subscriptionRangeStart, subscriptionRangeEnd];
}

class UsersErrorState extends UsersState {
  UsersErrorState({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
