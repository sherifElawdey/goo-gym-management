import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.error(bloc.runtimeType.toString(), error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
