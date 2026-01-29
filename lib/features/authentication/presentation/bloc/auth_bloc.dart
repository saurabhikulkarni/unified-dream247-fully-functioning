import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_handler.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../../shop/services/auth_service.dart' as shop_auth;
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthLocalDataSource localDataSource;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyOtpUseCase,
    required this.logoutUseCase,
    required this.localDataSource,
  }) : super(const AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await sendOtpUseCase(phone: event.phone);

    result.fold(
      (failure) => emit(AuthError(ErrorHandler.getErrorMessage(failure))),
      (_) => emit(OtpSent(event.phone)),
    );
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      phone: event.phone,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(ErrorHandler.getErrorMessage(failure))),
      (user) async {
        // Save unified session for shop and fantasy
        try {
          final authToken = await localDataSource.getAccessToken();
          final shopAuthService = shop_auth.AuthService();
          await shopAuthService.saveUnifiedLoginSession(
            phone: event.phone,
            name: user.name,
            userId: user.id,
            email: user.email,
            phoneVerified: true,
            authToken: authToken,
          );
          emit(Authenticated(user));
        } catch (e) {
          emit(AuthError(
              'Login successful but failed to save session: ${e.toString()}'));
        }
      },
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await registerUseCase(
      name: event.name,
      email: event.email,
      phone: event.phone,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(ErrorHandler.getErrorMessage(failure))),
      (user) async {
        // Save unified session for shop and fantasy after registration
        try {
          final authToken = await localDataSource.getAccessToken();
          final shopAuthService = shop_auth.AuthService();
          await shopAuthService.saveUnifiedLoginSession(
            phone: event.phone,
            name: user.name,
            userId: user.id,
            email: user.email,
            phoneVerified: true,
            authToken: authToken,
          );
          emit(Authenticated(user));
        } catch (e) {
          emit(AuthError(
              'Registration successful but failed to save session: ${e.toString()}'));
        }
      },
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    print('🔐 [AUTH_BLOC] Verifying OTP for phone: ${event.phone}');

    final result = await verifyOtpUseCase(
      phone: event.phone,
      otp: event.otp,
    );

    result.fold(
      (failure) {
        final errorMessage = ErrorHandler.getErrorMessage(failure);
        print('🔐 [AUTH_BLOC] OTP verification failed: $errorMessage');
        emit(AuthError(errorMessage));
      },
      (user) async {
        print(
            '🔐 [AUTH_BLOC] OTP verified successfully for user: ${user.name}');
        // Save unified session for shop and fantasy after successful OTP verification
        try {
          final authToken = await localDataSource.getAccessToken();
          final shopAuthService = shop_auth.AuthService();
          await shopAuthService.saveUnifiedLoginSession(
            phone: event.phone,
            name: user.name,
            userId: user.id,
            email: user.email,
            phoneVerified: true,
            authToken: authToken,
          );
          print('🔐 [AUTH_BLOC] Session saved successfully');
          emit(Authenticated(user));
        } catch (e) {
          print('🔐 [AUTH_BLOC] Failed to save session: $e');
          emit(AuthError(
              'OTP verification successful but failed to save session: ${e.toString()}'));
        }
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(ErrorHandler.getErrorMessage(failure))),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Check if user has a valid cached session
      final user = await localDataSource.getCachedUser();
      final accessToken = await localDataSource.getAccessToken();

      debugPrint('🔍 [AUTH_BLOC] Checking auth status...');
      debugPrint('   - Cached user: ${user != null ? user.name : "null"}');
      debugPrint(
          '   - Access token: ${accessToken != null ? "present" : "null"}');

      if (user != null && accessToken != null && accessToken.isNotEmpty) {
        debugPrint('✅ [AUTH_BLOC] Valid session found - user authenticated');
        emit(Authenticated(user.toEntity()));
      } else {
        debugPrint('❌ [AUTH_BLOC] No valid session - user unauthenticated');
        emit(const Unauthenticated());
      }
    } catch (e) {
      debugPrint('❌ [AUTH_BLOC] Error checking auth status: $e');
      emit(const Unauthenticated());
    }
  }
}
