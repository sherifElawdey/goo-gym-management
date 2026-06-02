import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/constants/app_constants.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit({required GymRepository repository})
      : _repository = repository,
        super(UsersInitialState());

  final GymRepository _repository;
  String query = '';
  String filter = 'all';
  DateTime? subscriptionRangeStart;
  DateTime? subscriptionRangeEnd;

  Future<void> load() async {
    emit(UsersLoadingState());
    await _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final allUsers = await _repository.loadUsers(query: query, filter: filter);
      final users = allUsers.where(_matchesSubscriptionDateRange).toList();
      emit(
        UsersLoadedState(
          users: users,
          query: query,
          filter: filter,
          subscriptionRangeStart: subscriptionRangeStart,
          subscriptionRangeEnd: subscriptionRangeEnd,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('UsersCubit.load', e, stackTrace: stackTrace);
      emit(UsersErrorState(message: AppLogger.userMessage(e)));
    }
  }

  bool _matchesSubscriptionDateRange(GymUser user) {
    if (subscriptionRangeStart == null && subscriptionRangeEnd == null) {
      return true;
    }
    final sub = user.activeSubscription;
    if (sub == null) return false;

    final subStart = _dayKey(sub.startDate);
    final subEnd = _dayKey(sub.endDate);
    final rangeStart =
        subscriptionRangeStart != null ? _dayKey(subscriptionRangeStart!) : null;
    final rangeEnd = subscriptionRangeEnd != null ? _dayKey(subscriptionRangeEnd!) : null;

    if (rangeStart != null && rangeEnd != null) {
      return !subStart.isAfter(rangeEnd) && !subEnd.isBefore(rangeStart);
    }
    if (rangeStart != null) {
      return !subEnd.isBefore(rangeStart);
    }
    if (rangeEnd != null) {
      return !subStart.isAfter(rangeEnd);
    }
    return true;
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> search(String q) async {
    query = q;
    await _fetchUsers();
  }

  Future<void> setFilter(String value) async {
    filter = value;
    await _fetchUsers();
  }

  Future<void> setSubscriptionDateRange({
    DateTime? start,
    DateTime? end,
  }) async {
    subscriptionRangeStart = start != null ? _dayKey(start) : null;
    subscriptionRangeEnd = end != null ? _dayKey(end) : null;
    await _fetchUsers();
  }

  Future<void> clearSubscriptionDateRange() async {
    subscriptionRangeStart = null;
    subscriptionRangeEnd = null;
    await _fetchUsers();
  }

  Future<List<Subscription>> loadUserSubscriptions(String userId) {
    return _repository.loadSubscriptions(userId);
  }

  Future<void> updateSubscriptionEndDate({
    required String subscriptionId,
    required DateTime endDate,
  }) async {
    try {
      await _repository.updateSubscriptionEndDate(
        subscriptionId: subscriptionId,
        endDate: endDate,
      );
      await _fetchUsers();
    } catch (e, stackTrace) {
      AppLogger.error('UsersCubit.updateSubscriptionEndDate', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> endSubscription({
    required String subscriptionId,
    required String userId,
  }) async {
    try {
      await _repository.endSubscription(
        subscriptionId: subscriptionId,
        userId: userId,
      );
      await _fetchUsers();
    } catch (e, stackTrace) {
      AppLogger.error('UsersCubit.endSubscription', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> addMember({
    required String name,
    required String phone,
    required DateTime startDate,
    double subscriptionFee = AppConstants.defaultMonthlySubscriptionFeeEgp,
    double discount = 0,
  }) async {
    try {
      await _repository.addMember(
        name: name,
        phone: phone,
        startDate: startDate,
        subscriptionFee: subscriptionFee,
        discount: discount,
      );
      await _fetchUsers();
    } catch (e, stackTrace) {
      AppLogger.error('UsersCubit.addMember', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateUser({
    required String userId,
    required String name,
    required String phone,
  }) async {
    try {
      await _repository.updateUser(userId: userId, name: name, phone: phone);
      await _fetchUsers();
    } catch (e, stackTrace) {
      AppLogger.error('UsersCubit.updateUser', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _repository.deleteUser(userId);
      await _fetchUsers();
    } catch (e, stackTrace) {
      AppLogger.error('UsersCubit.deleteUser', e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
