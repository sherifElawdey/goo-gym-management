part of 'attendance_cubit.dart';

sealed class AttendanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendanceInitialState extends AttendanceState {}

class AttendanceLoadingState extends AttendanceState {}

class AttendanceLoadedState extends AttendanceState {
  AttendanceLoadedState({
    required this.records,
    required this.selectedDate,
    required this.filter,
  });

  final List<AttendanceRecord> records;
  final DateTime selectedDate;
  final String filter;

  @override
  List<Object?> get props => [records, selectedDate, filter];
}

class AttendanceErrorState extends AttendanceState {
  AttendanceErrorState({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
