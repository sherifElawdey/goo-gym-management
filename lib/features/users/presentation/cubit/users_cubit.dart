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
  String genderFilter = 'all';
  DateTime? subscriptionMonth;
  String subscriptionSort = 'none';

  static DateTime _currentMonthKey() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  Future<void> load() async {
    emit(UsersLoadingState());
    if (filter == 'members' && subscriptionMonth == null) {
      subscriptionMonth = _currentMonthKey();
    }
    await _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      var allUsers = await _repository.loadUsers(
        query: query,
        filter: filter,
        genderFilter: genderFilter,
      );

      if (filter == 'members' && subscriptionMonth != null) {
        final monthUserIds =
            await _repository.userIdsWithSubscriptionInMonth(subscriptionMonth!);
        allUsers = allUsers.where((u) => monthUserIds.contains(u.id)).toList();
      }

      final users = _sortUsers(allUsers);

      emit(
        UsersLoadedState(
          users: users,
          query: query,
          filter: filter,
          genderFilter: genderFilter,
          subscriptionMonth: subscriptionMonth,
          subscriptionSort: subscriptionSort,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('UsersCubit.load', e, stackTrace: stackTrace);
      emit(UsersErrorState(message: AppLogger.userMessage(e)));
    }
  }

  List<GymUser> _sortUsers(List<GymUser> users) {
    if (subscriptionSort == 'none') return users;

    final sorted = List<GymUser>.from(users);
    int compareDates(DateTime? a, DateTime? b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    }

    sorted.sort((a, b) {
      final subA = a.activeSubscription;
      final subB = b.activeSubscription;
      final cmp = switch (subscriptionSort) {
        'start_asc' => compareDates(subA?.startDate, subB?.startDate),
        'start_desc' => compareDates(subB?.startDate, subA?.startDate),
        'end_asc' => compareDates(subA?.endDate, subB?.endDate),
        'end_desc' => compareDates(subB?.endDate, subA?.endDate),
        _ => 0,
      };
      return cmp != 0 ? cmp : a.name.compareTo(b.name);
    });
    return sorted;
  }

  DateTime _monthKey(DateTime d) => DateTime(d.year, d.month, 1);

  Future<void> search(String q) async {
    query = q;
    await _fetchUsers();
  }

  Future<void> setFilter(String value) async {
    filter = value;
    if (value == 'members') {
      subscriptionMonth ??= _currentMonthKey();
    } else {
      genderFilter = 'all';
      subscriptionMonth = null;
      subscriptionSort = 'none';
    }
    await _fetchUsers();
  }

  Future<void> setGenderFilter(String value) async {
    genderFilter = value;
    await _fetchUsers();
  }

  Future<void> setMembersGenderFilter(String value) async {
    filter = 'members';
    genderFilter = value;
    subscriptionMonth ??= _currentMonthKey();
    await _fetchUsers();
  }

  Future<void> setSubscriptionMonth(DateTime? month) async {
    subscriptionMonth = month != null ? _monthKey(month) : null;
    await _fetchUsers();
  }

  Future<void> clearSubscriptionMonth() async {
    subscriptionMonth = null;
    await _fetchUsers();
  }

  Future<void> setSubscriptionSort(String value) async {
    subscriptionSort = value;
    await _fetchUsers();
  }

  Future<List<Subscription>> loadUserSubscriptions(String userId) {
    return _repository.loadSubscriptions(userId);
  }

  /// All registered users for add-member name suggestions (does not change list state).
  Future<List<GymUser>> loadUsersForSuggestion() {
    return _repository.loadUsers(query: '', filter: 'all');
  }

  Future<void> updateSubscription({
    required String subscriptionId,
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
  }) async {
    try {
      await _repository.updateSubscription(
        subscriptionId: subscriptionId,
        startDate: startDate,
        endDate: endDate,
        amount: amount,
      );
      await _fetchUsers();
    } catch (e, stackTrace) {
      AppLogger.error('UsersCubit.updateSubscription', e, stackTrace: stackTrace);
      rethrow;
    }
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

  Future<void> renewMemberSubscription({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
  }) async {
    try {
      await _repository.renewMemberSubscription(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        amount: amount,
      );
      await _fetchUsers();
    } catch (e, stackTrace) {
      AppLogger.error('UsersCubit.renewMemberSubscription', e, stackTrace: stackTrace);
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
    UserGender gender = UserGender.male,
    double subscriptionFee = AppConstants.defaultMonthlySubscriptionFeeEgp,
    double discount = 0,
  }) async {
    try {
      await _repository.addMember(
        name: name,
        phone: phone,
        startDate: startDate,
        gender: gender,
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

  Future<int> softDeleteExpiredMembers(List<String> userIds) async {
    try {
      final count = await _repository.softDeleteExpiredMembers(userIds);
      await _fetchUsers();
      return count;
    } catch (e, stackTrace) {
      AppLogger.error('UsersCubit.softDeleteExpiredMembers', e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
