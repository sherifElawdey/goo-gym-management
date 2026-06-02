import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required GymRepository repository})
      : _repository = repository,
        super(DashboardInitialState());

  final GymRepository _repository;

  Future<void> load() async {
    emit(DashboardLoadingState());
    try {
      final stats = await _repository.loadDashboardStats();
      emit(DashboardLoadedState(stats: stats));
    } catch (e, stackTrace) {
      AppLogger.error('DashboardCubit.load', e, stackTrace: stackTrace);
      emit(DashboardErrorState(message: AppLogger.userMessage(e)));
    }
  }
}
