part of 'finance_cubit.dart';

sealed class FinanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FinanceInitialState extends FinanceState {}

class FinanceLoadingState extends FinanceState {}

class FinanceLoadedState extends FinanceState {
  FinanceLoadedState({
    required this.month,
    required this.monthlyRevenue,
    required this.maleRevenue,
    required this.femaleRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.currentBalance,
    required this.expenses,
  });

  final DateTime month;
  final double monthlyRevenue;
  final double maleRevenue;
  final double femaleRevenue;
  final double totalExpenses;
  final double netProfit;
  final double currentBalance;
  final List<Expense> expenses;

  @override
  List<Object?> get props => [
        month,
        monthlyRevenue,
        maleRevenue,
        femaleRevenue,
        totalExpenses,
        netProfit,
        currentBalance,
        expenses,
      ];
}

class FinanceErrorState extends FinanceState {
  FinanceErrorState({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
