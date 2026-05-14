import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/local_db/session_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(AuthEntity user) = AuthAuthenticated;
  const factory AuthState.error(String message) = AuthError;
}

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState.initial() = RegisterInitial;
  const factory RegisterState.loading() = RegisterLoading;
  const factory RegisterState.success() = RegisterSuccess;
  const factory RegisterState.error(String message) = RegisterError;
}

@freezed
class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState.initial() = ForgotPasswordInitial;
  const factory ForgotPasswordState.loading() = ForgotPasswordLoading;
  const factory ForgotPasswordState.success() = ForgotPasswordSuccess;
  const factory ForgotPasswordState.error(String message) = ForgotPasswordError;
}

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

@riverpod
Dio dio(Ref ref) => ref.watch(dioClientProvider);

@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) =>
    AuthRemoteDatasource(ref.watch(dioProvider));

@riverpod
AuthRepositoryImpl authRepository(Ref ref) => AuthRepositoryImpl(
      ref.watch(authRemoteDatasourceProvider),
      sessionService: SessionService.instance,
    );

@riverpod
LoginUseCase loginUseCase(Ref ref) =>
    LoginUseCase(ref.watch(authRepositoryProvider));

@riverpod
RegisterUseCase registerUseCase(Ref ref) =>
    RegisterUseCase(ref.watch(authRepositoryProvider));

@riverpod
ForgotPasswordUseCase forgotPasswordUseCase(Ref ref) =>
    ForgotPasswordUseCase(ref.watch(authRepositoryProvider));

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await ref.read(loginUseCaseProvider).call(
          email: email,
          password: password,
        );

    state = result.fold(
      (failure) => _mapFailureToState(failure),
      (user) => AuthState.authenticated(user),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState.initial();
  }

  AuthState _mapFailureToState(Failure failure) => switch (failure) {
        AuthFailure() => AuthState.error(failure.message),
        ValidationFailure() => AuthState.error(failure.message),
        NetworkFailure() => const AuthState.error('Pas de connexion internet'),
        _ => AuthState.error(failure.message),
      };
}

@riverpod
class RegisterNotifier extends _$RegisterNotifier {
  @override
  RegisterState build() => const RegisterState.initial();

  Future<void> register({
    required String nom,
    required String prenom,
    required String region,
    required String tel,
    required String password,
  }) async {
    state = const RegisterState.loading();

    final result = await ref.read(registerUseCaseProvider).call(
          nom: nom,
          prenom: prenom,
          region: region,
          tel: tel,
          password: password,
        );

    state = result.fold(
      (failure) => RegisterState.error(failure.message),
      (_) => const RegisterState.success(),
    );
  }

  void reset() {
    state = const RegisterState.initial();
  }
}

@riverpod
class ForgotPasswordNotifier extends _$ForgotPasswordNotifier {
  @override
  ForgotPasswordState build() => const ForgotPasswordState.initial();

  Future<void> submit({required String tel}) async {
    state = const ForgotPasswordState.loading();

    final result = await ref.read(forgotPasswordUseCaseProvider).call(tel: tel);

    state = result.fold(
      (failure) => ForgotPasswordState.error(failure.message),
      (_) => const ForgotPasswordState.success(),
    );
  }

  void reset() {
    state = const ForgotPasswordState.initial();
  }
}
