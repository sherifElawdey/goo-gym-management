import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_pro_manager/core/services/biometric_service.dart';
import 'package:gym_pro_manager/core/services/notification_service.dart';
import 'package:gym_pro_manager/data/repositories/firebase_gym_repository.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';
import 'package:gym_pro_manager/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gym_pro_manager/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:gym_pro_manager/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:gym_pro_manager/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:gym_pro_manager/features/users/presentation/cubit/users_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<BiometricService>(() => BiometricService());

  sl.registerLazySingleton<GymRepository>(
    () => FirebaseGymRepository(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      repository: sl<GymRepository>(),
      prefs: sl<SharedPreferences>(),
    ),
  );
  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(repository: sl<GymRepository>()),
  );
  sl.registerFactory<AttendanceCubit>(
    () => AttendanceCubit(repository: sl<GymRepository>()),
  );
  sl.registerFactory<UsersCubit>(
    () => UsersCubit(repository: sl<GymRepository>()),
  );
  sl.registerFactory<FinanceCubit>(
    () => FinanceCubit(repository: sl<GymRepository>()),
  );
}
