import 'package:equatable/equatable.dart';

class GymUser extends Equatable {
  const GymUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.isMember,
    required this.createdAt,
    this.activeSubscription,
  });

  final String id;
  final String name;
  final String phone;
  final bool isMember;
  final DateTime createdAt;
  final Subscription? activeSubscription;

  GymUser copyWith({
    Subscription? activeSubscription,
    bool clearSubscription = false,
  }) {
    return GymUser(
      id: id,
      name: name,
      phone: phone,
      isMember: isMember,
      createdAt: createdAt,
      activeSubscription:
          clearSubscription ? null : activeSubscription ?? this.activeSubscription,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, isMember, createdAt, activeSubscription];
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
  });

  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String status;
  final String? memberName;

  int get remainingDays => endDate.difference(DateTime.now()).inDays;

  @override
  List<Object?> get props => [id, userId, startDate, endDate, amount, status, memberName];
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

class DashboardStats extends Equatable {
  const DashboardStats({
    required this.totalMembers,
    required this.totalNonMembers,
    required this.monthlyRevenue,
    required this.currentBalance,
    required this.totalAttendanceToday,
    required this.expiringSubscriptions,
  });

  final int totalMembers;
  final int totalNonMembers;
  final double monthlyRevenue;
  final double currentBalance;
  final int totalAttendanceToday;
  final List<Subscription> expiringSubscriptions;

  @override
  List<Object?> get props => [
        totalMembers,
        totalNonMembers,
        monthlyRevenue,
        currentBalance,
        totalAttendanceToday,
        expiringSubscriptions,
      ];
}
