import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_pro_manager/core/constants/admin_roles.dart';
import 'package:gym_pro_manager/core/constants/app_constants.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';
import 'package:uuid/uuid.dart';

class FirebaseGymRepository implements GymRepository {
  FirebaseGymRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  @override
  Stream<bool> authChanges() => _auth.authStateChanges().map((user) => user != null);

  @override
  Future<String?> currentUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    try {
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (!adminDoc.exists) {
        return null;
      }
      return adminDoc.data()?['role'] as String? ?? AdminRoles.staff;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('FirebaseGymRepository.currentUserRole', e, stackTrace: stackTrace);
      if (e.code == 'permission-denied') {
        throw Exception(
          'Firestore permission denied. Deploy updated firestore.rules and ensure '
          'your user has an admins/{uid} document.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<bool> isGymBootstrapped() async {
    final doc = await _firestore.collection('gym_config').doc('app').get();
    return doc.exists;
  }

  @override
  Future<void> claimInitialAdmin() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to create an admin account.');
    }
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw Exception('Your Firebase account must have an email address.');
    }

    final batch = _firestore.batch();
    final adminRef = _firestore.collection('admins').doc(user.uid);
    batch.set(adminRef, {
      'id': user.uid,
      'email': email,
      'role': AdminRoles.admin,
      'permissions': 'full',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_firestore.collection('gym_config').doc('app'), {
      'bootstrappedBy': user.uid,
      'bootstrappedAt': FieldValue.serverTimestamp(),
      'gymName': 'Goo Gym',
    });
    await batch.commit();
  }

  @override
  Future<bool> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return true;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  Subscription _subscriptionFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Subscription(
      id: doc.id,
      userId: data['userId'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      amount: (data['amount'] as num).toDouble(),
      status: data['status'] as String? ?? 'active',
      memberName: data['memberName'] as String?,
    );
  }

  bool _isSubscriptionEnded(Subscription sub, DateTime todayKey) {
    if (sub.status == 'expired') return true;
    final endKey = DateTime(sub.endDate.year, sub.endDate.month, sub.endDate.day);
    return endKey.isBefore(todayKey);
  }

  Future<void> _commitBatches({
    required List<void Function(WriteBatch batch)> operations,
  }) async {
    const batchLimit = 500;
    for (var i = 0; i < operations.length; i += batchLimit) {
      final batch = _firestore.batch();
      final end = (i + batchLimit < operations.length) ? i + batchLimit : operations.length;
      for (var j = i; j < end; j++) {
        operations[j](batch);
      }
      await batch.commit();
    }
  }

  List<Subscription> _parseAllSubscriptions(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final list = snapshot.docs.map(_subscriptionFromDoc).toList();
    list.sort((a, b) => b.endDate.compareTo(a.endDate));
    return list;
  }

  ({int count, double total}) _sumSubscriptions(List<Subscription> subscriptions) {
    return (
      count: subscriptions.length,
      total: subscriptions.fold<double>(0, (acc, s) => acc + s.amount),
    );
  }

  ({
    List<AttendanceRecord> sessions,
    double total,
    int memberCount,
    double memberTotal,
    int visitorCount,
    double visitorTotal,
  }) _todaySessionTotals(List<AttendanceRecord> attendance) {
    var memberCount = 0;
    var visitorCount = 0;
    var memberTotal = 0.0;
    var visitorTotal = 0.0;
    for (final record in attendance) {
      if (record.userType == 'member') {
        memberCount++;
        memberTotal += record.amountPaid;
      } else {
        visitorCount++;
        visitorTotal += record.amountPaid;
      }
    }
    final total = attendance.fold<double>(0, (acc, e) => acc + e.amountPaid);
    return (
      sessions: attendance,
      total: total,
      memberCount: memberCount,
      memberTotal: memberTotal,
      visitorCount: visitorCount,
      visitorTotal: visitorTotal,
    );
  }

  @override
  Future<RevenueBreakdown> loadRevenueBreakdown() async {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final subscriptionsSnap = await _firestore.collection('subscriptions').get();
    final subscriptions = _parseAllSubscriptions(subscriptionsSnap);
    final subSum = _sumSubscriptions(subscriptions);
    final attendance = await attendanceByDate(todayKey);
    final sessions = _todaySessionTotals(attendance);

    return RevenueBreakdown(
      subscriptionCount: subSum.count,
      subscriptionTotal: subSum.total,
      subscriptions: subscriptions,
      todaySessionCount: attendance.length,
      todaySessionTotal: sessions.total,
      todayMemberSessionCount: sessions.memberCount,
      todayMemberSessionTotal: sessions.memberTotal,
      todayVisitorSessionCount: sessions.visitorCount,
      todayVisitorSessionTotal: sessions.visitorTotal,
      todaySessions: sessions.sessions,
    );
  }

  @override
  Future<DashboardStats> loadDashboardStats() async {
    final users = await _firestore.collection('users').get();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final attendance = await attendanceByDate(todayKey);
    final expenses = await loadExpensesByMonth(today);
    final memberIds = <String>{
      for (final doc in users.docs)
        if ((doc.data()['isMember'] ?? false) == true) doc.id,
    };
    final members = memberIds.length;
    final nonMembers = users.docs.length - members;
    final expiring = <Subscription>[];

    final subscriptionsSnap = await _firestore.collection('subscriptions').get();
    final subscriptions = _parseAllSubscriptions(subscriptionsSnap);
    final latestByUser = <String, Subscription>{};
    for (final sub in subscriptions) {
      final existing = latestByUser[sub.userId];
      if (existing == null || sub.startDate.isAfter(existing.startDate)) {
        latestByUser[sub.userId] = sub;
      }
    }
    for (final sub in latestByUser.values) {
      if (!memberIds.contains(sub.userId)) continue;
      if (sub.status != 'active') continue;
      final endKey = DateTime(sub.endDate.year, sub.endDate.month, sub.endDate.day);
      final remaining = endKey.difference(todayKey).inDays;
      if (remaining >= 0 && remaining <= 5) {
        expiring.add(sub);
      }
    }

    final subSum = _sumSubscriptions(subscriptions);
    final sessions = _todaySessionTotals(attendance);
    final revenue = subSum.total + sessions.total;
    final totalExpenses = expenses.fold<double>(0, (acc, e) => acc + e.amount);

    return DashboardStats(
      totalMembers: members,
      totalNonMembers: nonMembers,
      monthlyRevenue: revenue,
      currentBalance: revenue - totalExpenses,
      totalAttendanceToday: attendance.length,
      expiringSubscriptions: expiring..sort((a, b) => a.remainingDays.compareTo(b.remainingDays)),
    );
  }

  @override
  Future<List<AttendanceRecord>> attendanceByDate(DateTime date, {String? filter}) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    // Equality on attendanceDate avoids composite indexes (range + orderBy on other fields).
    final snapshot = await _firestore
        .collection('attendance')
        .where('attendanceDate', isEqualTo: Timestamp.fromDate(dayStart))
        .get();

    final records = snapshot.docs.map((doc) {
      final data = doc.data();
      return AttendanceRecord(
        id: doc.id,
        userId: data['userId'] as String,
        userType: data['userType'] as String,
        attendanceDate: (data['attendanceDate'] as Timestamp).toDate(),
        attendanceTime: (data['attendanceTime'] as Timestamp).toDate(),
        amountPaid: (data['amountPaid'] as num? ?? 0).toDouble(),
        userName: data['userName'] as String? ?? 'Unknown',
      );
    }).toList();

    final filtered = filter == null || filter == 'all'
        ? records
        : records.where((r) => r.userType == filter).toList();

    filtered.sort((a, b) => b.attendanceTime.compareTo(a.attendanceTime));
    return filtered;
  }

  @override
  Future<void> addAttendanceForUser({required GymUser user, required DateTime now}) async {
    await _firestore.collection('attendance').add({
      'id': _uuid.v4(),
      'userId': user.id,
      'userName': user.name,
      'userType': user.isMember ? 'member' : 'non_member',
      'attendanceDate': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
      'attendanceTime': Timestamp.fromDate(now),
      'amountPaid': 0,
    });
  }

  @override
  Future<void> addDailyVisitor({
    required String name,
    required String phone,
    required double amount,
    required DateTime now,
  }) async {
    final userRef = _firestore.collection('users').doc();
    await userRef.set({
      'id': userRef.id,
      'name': name,
      'phone': phone,
      'isMember': false,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    await _firestore.collection('attendance').add({
      'id': _uuid.v4(),
      'userId': userRef.id,
      'userName': name,
      'userType': 'non_member',
      'attendanceDate': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
      'attendanceTime': Timestamp.fromDate(now),
      'amountPaid': amount,
    });
  }

  Future<Map<String, Subscription>> _latestSubscriptionsByUser() async {
    final snapshot = await _firestore.collection('subscriptions').get();
    final latest = <String, Subscription>{};
    for (final doc in snapshot.docs) {
      final sub = _subscriptionFromDoc(doc);
      final existing = latest[sub.userId];
      if (existing == null || sub.startDate.isAfter(existing.startDate)) {
        latest[sub.userId] = sub;
      }
    }
    return latest;
  }

  @override
  Future<List<GymUser>> loadUsers({String query = '', String filter = 'all'}) async {
    final subscriptionsByUser = await _latestSubscriptionsByUser();
    final snapshot = await _firestore.collection('users').orderBy('name').limit(100).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return GymUser(
        id: doc.id,
        name: data['name'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        isMember: data['isMember'] as bool? ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        activeSubscription: subscriptionsByUser[doc.id],
      );
    }).where((user) {
      final q = query.trim().toLowerCase();
      final passesFilter = filter == 'all' ||
          (filter == 'members' && user.isMember) ||
          (filter == 'non_members' && !user.isMember);
      return passesFilter &&
          (q.isEmpty || user.name.toLowerCase().contains(q) || user.phone.contains(q));
    }).toList();
  }

  @override
  Future<void> addMember({
    required String name,
    required String phone,
    required DateTime startDate,
    double subscriptionFee = AppConstants.defaultMonthlySubscriptionFeeEgp,
    double discount = 0,
  }) async {
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final endDate = normalizedStart.add(
      const Duration(days: AppConstants.defaultSubscriptionDurationDays),
    );
    final amount = subscriptionFee - discount;
    final now = DateTime.now();

    final userRef = _firestore.collection('users').doc();
    final subscriptionRef = _firestore.collection('subscriptions').doc();

    final batch = _firestore.batch();
    batch.set(userRef, {
      'id': userRef.id,
      'name': name,
      'phone': phone,
      'isMember': true,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    batch.set(subscriptionRef, {
      'userId': userRef.id,
      'startDate': Timestamp.fromDate(normalizedStart),
      'endDate': Timestamp.fromDate(endDate),
      'amount': amount,
      'discount': discount,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<void> updateUser({
    required String userId,
    required String name,
    required String phone,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'name': name,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteUser(String userId) async {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userName = userDoc.data()?['name'] as String? ?? '';

    final subscriptions = await _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .get();
    final attendance = await _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .get();

    final preserveUpdates = <void Function(WriteBatch)>[];
    final deleteOps = <void Function(WriteBatch)>[];

    for (final doc in subscriptions.docs) {
      final sub = _subscriptionFromDoc(doc);
      if (_isSubscriptionEnded(sub, todayKey)) {
        preserveUpdates.add(
          (batch) => batch.update(doc.reference, {
            'memberName': userName,
            'userDeleted': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }),
        );
      } else {
        deleteOps.add((batch) => batch.delete(doc.reference));
      }
    }

    for (final doc in attendance.docs) {
      deleteOps.add((batch) => batch.delete(doc.reference));
    }
    deleteOps.add((batch) => batch.delete(_firestore.collection('users').doc(userId)));

    if (preserveUpdates.isNotEmpty) {
      await _commitBatches(operations: preserveUpdates);
    }
    if (deleteOps.isNotEmpty) {
      await _commitBatches(operations: deleteOps);
    }
  }

  @override
  Future<List<Subscription>> loadSubscriptions(String userId) async {
    final snapshot = await _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .get();
    final subscriptions = snapshot.docs.map(_subscriptionFromDoc).toList();
    subscriptions.sort((a, b) => b.startDate.compareTo(a.startDate));
    return subscriptions;
  }

  @override
  Future<void> renewSubscription({
    required String userId,
    required int durationDays,
    required double amount,
    required DateTime startDate,
  }) async {
    final endDate = startDate.add(Duration(days: durationDays));
    await _firestore.collection('subscriptions').add({
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'amount': amount,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('users').doc(userId).update({'isMember': true});
  }

  @override
  Future<void> updateSubscriptionEndDate({
    required String subscriptionId,
    required DateTime endDate,
  }) async {
    final normalized = DateTime(endDate.year, endDate.month, endDate.day);
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final status = normalized.isBefore(todayKey) ? 'expired' : 'active';
    await _firestore.collection('subscriptions').doc(subscriptionId).update({
      'endDate': Timestamp.fromDate(normalized),
      'status': status,
    });
  }

  @override
  Future<void> cancelMembership(String userId) async {
    await _firestore.collection('users').doc(userId).update({'isMember': false});
  }

  @override
  Future<void> endSubscription({
    required String subscriptionId,
    required String userId,
  }) async {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final batch = _firestore.batch();
    batch.update(_firestore.collection('subscriptions').doc(subscriptionId), {
      'endDate': Timestamp.fromDate(todayKey),
      'status': 'expired',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_firestore.collection('users').doc(userId), {
      'isMember': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<List<Expense>> loadExpensesByMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final snapshot = await _firestore
        .collection('expenses')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .get();
    final expenses = snapshot.docs.map((doc) {
      final data = doc.data();
      return Expense(
        id: doc.id,
        title: data['title'] as String? ?? '',
        category: data['category'] as String? ?? 'Other',
        amount: (data['amount'] as num? ?? 0).toDouble(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
    expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return expenses;
  }

  @override
  Future<Expense> addExpense({
    required String title,
    required String category,
    required double amount,
    required String notes,
  }) async {
    final now = DateTime.now();
    final ref = await _firestore.collection('expenses').add({
      'title': title,
      'category': category,
      'amount': amount,
      'notes': notes,
      'createdAt': Timestamp.fromDate(now),
      'createdBy': _auth.currentUser?.uid,
    });
    return Expense(
      id: ref.id,
      title: title,
      category: category,
      amount: amount,
      createdAt: now,
    );
  }
}
