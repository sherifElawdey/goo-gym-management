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
      final monthlyFinance = await _repository.loadMonthlyFinance(_selectedMonth);
      final expenses = await _repository.loadExpensesByMonth(_selectedMonth);
      _emitLoaded(monthlyFinance: monthlyFinance, expenses: expenses);
    } catch (e, stackTrace) {
      AppLogger.error('FinanceCubit.load', e, stackTrace: stackTrace);
      emit(FinanceErrorState(message: AppLogger.userMessage(e)));
    }
  }

  void _emitLoaded({
    required MonthlyFinance monthlyFinance,
    required List<Expense> expenses,
  }) {
    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final revenue = monthlyFinance.totalRevenue;
    emit(
      FinanceLoadedState(
        month: monthlyFinance.month,
        monthlyFinance: monthlyFinance,
        monthlyRevenue: revenue,
        maleRevenue: monthlyFinance.maleRevenue,
        femaleRevenue: monthlyFinance.femaleRevenue,
        currentBalance: revenue - totalExpenses,
        totalExpenses: totalExpenses,
        netProfit: revenue - totalExpenses,
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

      final monthlyFinance = await _repository.loadMonthlyFinance(currentMonth);
      if (state is FinanceLoadedState) {
        final loaded = state as FinanceLoadedState;
        final isViewingCurrentMonth =
            loaded.month.year == currentMonth.year && loaded.month.month == currentMonth.month;
        if (isViewingCurrentMonth) {
          final expenses = [expense, ...loaded.expenses]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _emitLoaded(monthlyFinance: monthlyFinance, expenses: expenses);
          return;
        }
      }
      final expenses = await _repository.loadExpensesByMonth(currentMonth);
      _emitLoaded(monthlyFinance: monthlyFinance, expenses: expenses);
    } catch (e, stackTrace) {
      AppLogger.error('FinanceCubit.addExpense', e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
