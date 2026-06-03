import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';

part 'finance_state.dart';

class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit({required GymRepository repository})
      : _repository = repository,
        super(FinanceInitialState());

  final GymRepository _repository;
  DateTime _selectedMonth = DateTime.now();

  Future<void> load([DateTime? month]) async {
    if (month != null) {
      _selectedMonth = DateTime(month.year, month.month);
    } else if (state is! FinanceLoadedState) {
      _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    }
    emit(FinanceLoadingState());
    await _fetch();
  }

  Future<void> refresh() async {
    emit(FinanceLoadingState());
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final dashboard = await _repository.loadDashboardStats();
      final genderRevenue = await _repository.loadGenderRevenue();
      final expenses = await _repository.loadExpensesByMonth(_selectedMonth);
      _emitLoaded(
        month: _selectedMonth,
        monthlyRevenue: dashboard.monthlyRevenue,
        maleRevenue: genderRevenue.maleRevenue,
        femaleRevenue: genderRevenue.femaleRevenue,
        expenses: expenses,
      );
    } catch (e, stackTrace) {
      AppLogger.error('FinanceCubit.load', e, stackTrace: stackTrace);
      emit(FinanceErrorState(message: AppLogger.userMessage(e)));
    }
  }

  void _emitLoaded({
    required DateTime month,
    required double monthlyRevenue,
    required double maleRevenue,
    required double femaleRevenue,
    required List<Expense> expenses,
  }) {
    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    emit(
      FinanceLoadedState(
        month: month,
        monthlyRevenue: monthlyRevenue,
        maleRevenue: maleRevenue,
        femaleRevenue: femaleRevenue,
        currentBalance: monthlyRevenue - totalExpenses,
        totalExpenses: totalExpenses,
        netProfit: monthlyRevenue - totalExpenses,
        expenses: expenses,
      ),
    );
  }

  Future<void> addExpense({
    required String title,
    required String category,
    required double amount,
    String notes = '',
  }) async {
    try {
      final expense = await _repository.addExpense(
        title: title,
        category: category,
        amount: amount,
        notes: notes,
      );
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      _selectedMonth = currentMonth;

      final dashboard = await _repository.loadDashboardStats();
      final genderRevenue = await _repository.loadGenderRevenue();
      if (state is FinanceLoadedState) {
        final loaded = state as FinanceLoadedState;
        final isViewingCurrentMonth =
            loaded.month.year == currentMonth.year && loaded.month.month == currentMonth.month;
        if (isViewingCurrentMonth) {
          final expenses = [expense, ...loaded.expenses]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _emitLoaded(
            month: currentMonth,
            monthlyRevenue: dashboard.monthlyRevenue,
            maleRevenue: genderRevenue.maleRevenue,
            femaleRevenue: genderRevenue.femaleRevenue,
            expenses: expenses,
          );
          return;
        }
      }
      final expenses = await _repository.loadExpensesByMonth(currentMonth);
      _emitLoaded(
        month: currentMonth,
        monthlyRevenue: dashboard.monthlyRevenue,
        maleRevenue: genderRevenue.maleRevenue,
        femaleRevenue: genderRevenue.femaleRevenue,
        expenses: expenses,
      );
    } catch (e, stackTrace) {
      AppLogger.error('FinanceCubit.addExpense', e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
