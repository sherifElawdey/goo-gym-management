import 'package:equatable/equatable.dart';

enum UserGender { male, female }

extension UserGenderFirestore on UserGender {
  String get firestoreValue => name;

  static UserGender fromFirestore(String? value) =>
      value?.trim().toLowerCase() == 'female' ? UserGender.female : UserGender.male;
}

class GymUser extends Equatable {
  const GymUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.isMember,
    required this.createdAt,
    this.gender = UserGender.male,
    this.isDeleted = false,
    this.activeSubscription,
  });

  final String id;
  final String name;
  final String phone;
  final bool isMember;
  final DateTime createdAt;
  final UserGender gender;
  final bool isDeleted;
  final Subscription? activeSubscription;

  GymUser copyWith({
    Subscription? activeSubscription,
    bool clearSubscription = false,
    UserGender? gender,
    bool? isDeleted,
    bool? isMember,
  }) {
    return GymUser(
      id: id,
      name: name,
      phone: phone,
      isMember: isMember ?? this.isMember,
      createdAt: createdAt,
      gender: gender ?? this.gender,
      isDeleted: isDeleted ?? this.isDeleted,
      activeSubscription:
          clearSubscription ? null : activeSubscription ?? this.activeSubscription,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, phone, isMember, createdAt, gender, isDeleted, activeSubscription];
}

class Subscription extends Equatable {
  const Subscription({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.status,
    this.memberName,
    this.createdAt,
  });

  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String status;
  final String? memberName;
  final DateTime? createdAt;

  DateTime get paymentDate => createdAt ?? startDate;

  int get remainingDays => endDate.difference(DateTime.now()).inDays;

  int remainingDaysFrom(DateTime todayKey) {
    final endKey = DateTime(endDate.year, endDate.month, endDate.day);
    return endKey.difference(todayKey).inDays;
  }

  @override
  List<Object?> get props => [id, userId, startDate, endDate, amount, status, memberName, createdAt];
}

class MonthlyFinance extends Equatable {
  const MonthlyFinance({
    required this.month,
    required this.subscriptionRevenue,
    required this.sessionRevenue,
    required this.maleRevenue,
    required this.femaleRevenue,
    required this.subscriptions,
    required this.sessions,
  });

  final DateTime month;
  final double subscriptionRevenue;
  final double sessionRevenue;
  final double maleRevenue;
  final double femaleRevenue;
  final List<Subscription> subscriptions;
  final List<AttendanceRecord> sessions;

  double get totalRevenue => subscriptionRevenue + sessionRevenue;

  @override
  List<Object?> get props => [
        month,
        subscriptionRevenue,
        sessionRevenue,
        maleRevenue,
        femaleRevenue,
        subscriptions,
        sessions,
      ];
}

class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.id,
    required this.userId,
    required this.userType,
    required this.attendanceDate,
    required this.attendanceTime,
    required this.amountPaid,
    required this.userName,
  });

  final String id;
  final String userId;
  final String userType;
  final DateTime attendanceDate;
  final DateTime attendanceTime;
  final double amountPaid;
  final String userName;

  @override
  List<Object?> get props =>
      [id, userId, userType, attendanceDate, attendanceTime, amountPaid, userName];
}

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, title, category, amount, createdAt];
}

class RevenueBreakdown extends Equatable {
  const RevenueBreakdown({
    required this.subscriptionCount,
    required this.subscriptionTotal,
    required this.subscriptions,
    required this.todaySessionCount,
    required this.todaySessionTotal,
    required this.todayMemberSessionCount,
    required this.todayMemberSessionTotal,
    required this.todayVisitorSessionCount,
    required this.todayVisitorSessionTotal,
    required this.todaySessions,
  });

  final int subscriptionCount;
  final double subscriptionTotal;
  final List<Subscription> subscriptions;
  final int todaySessionCount;
  final double todaySessionTotal;
  final int todayMemberSessionCount;
  final double todayMemberSessionTotal;
  final int todayVisitorSessionCount;
  final double todayVisitorSessionTotal;
  final List<AttendanceRecord> todaySessions;

  double get totalRevenue => subscriptionTotal + todaySessionTotal;

  @override
  List<Object?> get props => [
        subscriptionCount,
        subscriptionTotal,
        subscriptions,
        todaySessionCount,
        todaySessionTotal,
        todayMemberSessionCount,
        todayMemberSessionTotal,
        todayVisitorSessionCount,
        todayVisitorSessionTotal,
        todaySessions,
      ];
}

class GenderRevenueBreakdown extends Equatable {
  const GenderRevenueBreakdown({
    required this.maleRevenue,
    required this.femaleRevenue,
  });

  final double maleRevenue;
  final double femaleRevenue;

  @override
  List<Object?> get props => [maleRevenue, femaleRevenue];
}

class DashboardStats extends Equatable {
  const DashboardStats({
    required this.totalMembers,
    required this.maleMembers,
    required this.femaleMembers,
    required this.totalNonMembers,
    required this.monthlyRevenue,
    required this.currentBalance,
    required this.totalAttendanceToday,
    required this.expiringSubscriptions,
    required this.endedSubscriptions,
  });

  final int totalMembers;
  final int maleMembers;
  final int femaleMembers;
  final int totalNonMembers;
  final double monthlyRevenue;
  final double currentBalance;
  final int totalAttendanceToday;
  final List<Subscription> expiringSubscriptions;
  final List<Subscription> endedSubscriptions;

  @override
  List<Object?> get props => [
        totalMembers,
        maleMembers,
        femaleMembers,
        totalNonMembers,
        monthlyRevenue,
        currentBalance,
        totalAttendanceToday,
        expiringSubscriptions,
        endedSubscriptions,
      ];
}
