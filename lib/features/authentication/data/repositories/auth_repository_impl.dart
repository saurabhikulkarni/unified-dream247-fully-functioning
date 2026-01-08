import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Authentication repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login({
    required String phone,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final authResponse = await remoteDataSource.login(
        phone: phone,
        password: password,
      );

      // Cache user and tokens
      await localDataSource.cacheUser(authResponse.user);
      await localDataSource.saveAccessToken(authResponse.accessToken);
      if (authResponse.refreshToken != null) {
        await localDataSource.saveRefreshToken(authResponse.refreshToken!);
      }

      return Right(authResponse.user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final authResponse = await remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      // Cache user and tokens
      await localDataSource.cacheUser(authResponse.user);
      await localDataSource.saveAccessToken(authResponse.accessToken);
      if (authResponse.refreshToken != null) {
        await localDataSource.saveRefreshToken(authResponse.refreshToken!);
      }

      return Right(authResponse.user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final authResponse = await remoteDataSource.verifyOtp(
        phone: phone,
        otp: otp,
      );

      // Cache user and tokens
      await localDataSource.cacheUser(authResponse.user);
      await localDataSource.saveAccessToken(authResponse.accessToken);
      if (authResponse.refreshToken != null) {
        await localDataSource.saveRefreshToken(authResponse.refreshToken!);
      }

      return Right(authResponse.user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
      await localDataSource.clearAuthData();
      return const Right(null);
    } on ServerException catch (e) {
      // Still clear local data even if server logout fails
      await localDataSource.clearAuthData();
      return Left(ServerFailure(e.message, code: e.statusCode));
    } catch (e) {
      await localDataSource.clearAuthData();
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }
}
