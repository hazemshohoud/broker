import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../services/cloudinary_service.dart';

import '../../features/account/data/datasources/account_remote_data_source.dart';
import '../../features/account/data/repositories/account_repository_impl.dart';
import '../../features/account/domain/repositories/account_repository.dart';
import '../../features/account/domain/usecases/get_profile.dart';
import '../../features/account/domain/usecases/update_payout_details.dart';
import '../../features/account/presentation/cubit/account_cubit.dart';
import '../../features/admin/data/datasources/admin_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/presentation/cubit/admin_auth_cubit.dart';
import '../../features/admin/presentation/cubit/admin_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_session_status.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/clients/data/datasources/clients_remote_data_source.dart';
import '../../features/clients/data/repositories/clients_repository_impl.dart';
import '../../features/clients/domain/repositories/clients_repository.dart';
import '../../features/clients/domain/usecases/add_client.dart';
import '../../features/clients/domain/usecases/delete_client.dart';
import '../../features/clients/domain/usecases/get_clients.dart';
import '../../features/clients/presentation/cubit/clients_cubit.dart';
import '../../features/commissions/data/datasources/commissions_remote_data_source.dart';
import '../../features/commissions/data/repositories/commissions_repository_impl.dart';
import '../../features/commissions/domain/repositories/commissions_repository.dart';
import '../../features/commissions/domain/usecases/get_wallet.dart';
import '../../features/commissions/domain/usecases/request_withdrawal.dart';
import '../../features/commissions/presentation/cubit/commissions_cubit.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_compounds.dart';
import '../../features/home/domain/usecases/get_developers.dart';
import '../../features/home/domain/usecases/get_filter_options.dart';
import '../../features/home/domain/usecases/get_offers.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/registration/data/datasources/registration_remote_data_source.dart';
import '../../features/onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../features/registration/data/repositories/registration_repository_impl.dart';
import '../../features/registration/domain/repositories/registration_repository.dart';
import '../../features/registration/domain/usecases/submit_registration.dart';
import '../../features/registration/presentation/cubit/registration_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  _initExternal();
  _initAuth();
  _initHome();
  _initRegistration();
  _initCommissions();
  _initClients();
  _initAccount();
  _initAdmin();
  _initNotifications();
}

void _initExternal() {
  sl
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FirebaseFirestore.instance)
    ..registerLazySingleton(() => FirebaseStorage.instance)
    ..registerLazySingleton<CloudinaryService>(() => CloudinaryService())
    ..registerLazySingleton<OnboardingLocalDataSource>(
      () => const OnboardingLocalDataSourceImpl(),
    );
}

void _initAuth() {
  sl
    ..registerFactory(
      () => AuthCubit(getSessionStatus: sl(), signIn: sl(), signOut: sl()),
    )
    ..registerLazySingleton(() => GetSessionStatus(sl()))
    ..registerLazySingleton(() => SignIn(sl()))
    ..registerLazySingleton(() => SignOut(sl()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(auth: sl(), firestore: sl()),
    );
}

void _initHome() {
  sl
    ..registerFactory(
      () => HomeCubit(
        getDevelopers: sl(),
        getOffers: sl(),
        getCompounds: sl(),
        getFilterOptions: sl(),
      ),
    )
    ..registerLazySingleton(() => GetDevelopers(sl()))
    ..registerLazySingleton(() => GetOffers(sl()))
    ..registerLazySingleton(() => GetCompounds(sl()))
    ..registerLazySingleton(() => GetFilterOptions(sl()))
    ..registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()))
    ..registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(sl()),
    );
}

void _initRegistration() {
  sl
    ..registerFactory(() => RegistrationCubit(sl()))
    ..registerLazySingleton(() => SubmitRegistration(sl()))
    ..registerLazySingleton<RegistrationRepository>(
      () => RegistrationRepositoryImpl(sl()),
    )
    ..registerLazySingleton<RegistrationRemoteDataSource>(
      () => RegistrationRemoteDataSourceImpl(
        auth: sl(),
        firestore: sl(),
        cloudinaryService: sl(),
      ),
    );
}

void _initCommissions() {
  sl
    ..registerFactory(
      () => CommissionsCubit(getWallet: sl(), requestWithdrawal: sl()),
    )
    ..registerLazySingleton(() => GetWallet(sl()))
    ..registerLazySingleton(() => RequestWithdrawal(sl()))
    ..registerLazySingleton<CommissionsRepository>(
      () => CommissionsRepositoryImpl(sl()),
    )
    ..registerLazySingleton<CommissionsRemoteDataSource>(
      () => CommissionsRemoteDataSourceImpl(auth: sl(), firestore: sl()),
    );
}

void _initClients() {
  sl
    ..registerFactory(
      () => ClientsCubit(
        getClients: sl(),
        getCompoundNames: sl(),
        addClient: sl(),
        deleteClient: sl(),
      ),
    )
    ..registerLazySingleton(() => GetClients(sl()))
    ..registerLazySingleton(() => GetCompoundNames(sl()))
    ..registerLazySingleton(() => AddClient(sl()))
    ..registerLazySingleton(() => DeleteClient(sl()))
    ..registerLazySingleton<ClientsRepository>(
      () => ClientsRepositoryImpl(sl()),
    )
    ..registerLazySingleton<ClientsRemoteDataSource>(
      () => ClientsRemoteDataSourceImpl(auth: sl(), firestore: sl()),
    );
}

void _initAccount() {
  sl
    ..registerFactory(
      () => AccountCubit(
        getProfile: sl(),
        signOut: sl(),
        updatePayoutDetails: sl(),
      ),
    )
    ..registerLazySingleton(() => GetProfile(sl()))
    ..registerLazySingleton(() => UpdatePayoutDetails(sl()))
    ..registerLazySingleton<AccountRepository>(
      () => AccountRepositoryImpl(sl()),
    )
    ..registerLazySingleton<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(auth: sl(), firestore: sl()),
    );
}

void _initAdmin() {
  sl
    ..registerFactory(() => AdminAuthCubit())
    ..registerFactory(() => AdminCubit(sl()))
    ..registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(sl()))
    ..registerLazySingleton<AdminRemoteDataSource>(
      () => AdminRemoteDataSourceImpl(
        firestore: sl(),
        cloudinaryService: sl(),
      ),
    );
}

void _initNotifications() {
  sl
    ..registerLazySingleton<NotificationsRemoteDataSource>(
      () => NotificationsRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<NotificationsCubit>(
      () => NotificationsCubit(remoteDataSource: sl()),
    );
}


