import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/send_otp_usecase.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/domain/usecases/register_usecase.dart';
import '../../features/authentication/domain/usecases/verify_otp_usecase.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/fantasy/accounts/data/managers/game_tokens_cache.dart';
import '../../features/fantasy/accounts/data/services/game_tokens_service.dart';
import '../../features/fantasy/accounts/data/services/contest_join_service.dart';
import '../../features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import '../network/api_client.dart';
import '../network/graphql_client.dart';
import '../network/network_info.dart';
import '../network/rest_client.dart';
import '../services/user_service.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection
@InjectableInit()
Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage();
  getIt.registerLazySingleton(() => secureStorage);

  final connectivity = Connectivity();
  getIt.registerLazySingleton(() => connectivity);

  // Core
  getIt.registerLazySingleton(() => NetworkInfo(getIt()));
  getIt.registerLazySingleton(() => RestClient(getIt()));
  getIt.registerLazySingleton(() => GraphQLClientService());
  getIt.registerLazySingleton(
    () => ApiClient(
      graphQLClient: getIt(),
      restClient: getIt(),
    ),
  );
  
  // Services
  getIt.registerLazySingleton(() => UserService(getIt()));
  
  // Fantasy - API Clients
  getIt.registerLazySingleton(() => ApiImplWithAccessToken());
  
  // Fantasy - Game Tokens
  getIt.registerLazySingleton(() => GameTokensCache());
  getIt.registerLazySingleton(
    () => GameTokensService(
      getIt<ApiImplWithAccessToken>(),
      getIt<GameTokensCache>(),
    ),
  );
  
  // Fantasy - Contest Operations
  getIt.registerLazySingleton(
    () => ContestJoinService(
      getIt<ApiImplWithAccessToken>(),
      getIt<GameTokensCache>(),
    ),
  );

  // Authentication
  // Data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: getIt(),
      sharedPreferences: getIt(),
    ),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(restClient: getIt()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => SendOtpUseCase(getIt()));
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));

  // BLoC
  getIt.registerFactory(
    () => AuthBloc(
      sendOtpUseCase: getIt(),
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      verifyOtpUseCase: getIt(),
      logoutUseCase: getIt(),
      localDataSource: getIt(),
    ),
  );
}
