import 'package:gym_pro_manager/core/constants/app_constants.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';

abstract class GymRepository {
  Future<bool> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Stream<bool> authChanges();

  Future<String?> currentUserRole();

  Future<bool> isGymBootstrapped();

  /// Creates the first `admin` account (full access) for the signed-in Firebase user.
  Future<void> claimInitialAdmin();

  Future<DashboardStats> loadDashboardStats();

  Future<RevenueBreakdown> loadRevenueBreakdown();

  Future<GenderRevenueBreakdown> loadGenderRevenue();

  Future<int> backfillAllUsersGenderToMale();

  Future<List<AttendanceRecord>> attendanceByDate(DateTime date, {String? filter});

  Future<void> addAttendanceForUser({
    required GymUser user,
    required DateTime now,
  });

  Future<void> addDailyVisitor({
    required String name,
    required String phone,
    required double amount,
    required DateTime now,
  });

  Future<List<GymUser>> loadUsers({String query = '', String filter = 'all'});

  Future<void> addMember({
    required String name,
    required String phone,
    required DateTime startDate,
    UserGender gender = UserGender.male,
    double subscriptionFee = AppConstants.defaultMonthlySubscriptionFeeEgp,
    double discount = 0,
  });

  Future<void> updateUser({
    required String userId,
    required String name,
    required String phone,
  });

  Future<void> deleteUser(String userId);

  Future<List<Subscription>> loadSubscriptions(String userId);

  Future<void> renewSubscription({
    required String userId,
    required int durationDays,
    required double amount,
    required DateTime startDate,
  });

  Future<void> updateSubscriptionEndDate({
    required String subscriptionId,
    required DateTime endDate,
  });

  Future<void> cancelMembership(String userId);

  Future<void> endSubscription({
    required String subscriptionId,
    required String userId,
  });

  Future<List<Expense>> loadExpensesByMonth(DateTime month);

  Future<Expense> addExpense({
    required String title,
    required String category,
    required double amount,
    required String notes,
  });
}
