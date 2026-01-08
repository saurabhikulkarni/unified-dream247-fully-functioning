import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../network/graphql_client.dart';
import '../network/network_info.dart';
import '../network/rest_client.dart';

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
  getIt.registerLazySingleton(() => GraphQLClientService(getIt()));
  getIt.registerLazySingleton(
    () => ApiClient(
      graphQLClient: getIt(),
      restClient: getIt(),
    ),
  );

  // Note: Feature-specific dependencies will be registered separately
  // in their respective modules using @injectable annotation
}
