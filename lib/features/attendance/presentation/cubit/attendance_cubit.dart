import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit({required GymRepository repository})
      : _repository = repository,
        super(AttendanceInitialState());

  final GymRepository _repository;

  DateTime selectedDate = DateTime.now();
  String filter = 'all';

  Future<void> load() async {
    emit(AttendanceLoadingState());
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await _repository.attendanceByDate(selectedDate, filter: filter);
      emit(AttendanceLoadedState(records: data, selectedDate: selectedDate, filter: filter));
    } catch (e, stackTrace) {
      AppLogger.error('AttendanceCubit.load', e, stackTrace: stackTrace);
      emit(AttendanceErrorState(message: AppLogger.userMessage(e)));
    }
  }

  Future<void> setFilter(String nextFilter) async {
    filter = nextFilter;
    await load();
  }

  Future<void> setDate(DateTime date) async {
    selectedDate = date;
    await load();
  }

  Future<List<GymUser>> loadMembers({String query = ''}) {
    return _repository.loadUsers(query: query, filter: 'members');
  }

  Future<void> registerMemberAttendance(GymUser user) async {
    try {
      await _repository.addAttendanceForUser(
        user: user,
        now: _checkInTimeForSelectedDate(),
      );
      await _fetch();
    } catch (e, stackTrace) {
      AppLogger.error('AttendanceCubit.registerMemberAttendance', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> addDailyVisitor({
    required String name,
    required String phone,
    required double amount,
  }) async {
    try {
      await _repository.addDailyVisitor(
        name: name,
        phone: phone,
        amount: amount,
        now: _checkInTimeForSelectedDate(),
      );
      await _fetch();
    } catch (e, stackTrace) {
      AppLogger.error('AttendanceCubit.addDailyVisitor', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  DateTime _checkInTimeForSelectedDate() {
    final now = DateTime.now();
    final day = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return now;
    return day.add(const Duration(hours: 12));
  }
}
