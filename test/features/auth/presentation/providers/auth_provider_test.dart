import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:agri_mada/features/auth/domain/entities/auth_entity.dart';
import 'package:agri_mada/features/auth/domain/usecases/login_usecase.dart';
import 'package:agri_mada/features/auth/presentation/providers/auth_provider.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockAuthRepositoryImpl extends Mock implements AuthRepositoryImpl {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockLoginUseCase mockUseCase;
  late MockAuthRepositoryImpl mockAuthRepository;

  const tTel = '0341234567';
  const tPassword = 'password123';
  const UserProfile tUser = UserProfile(
    userId: 'user-001',
    email: 'user@agrimada.mg',
    phoneNumber: tTel,
  );

  setUp(() {
    mockUseCase = MockLoginUseCase();
    mockAuthRepository = MockAuthRepositoryImpl();

    when(() => mockAuthRepository.logout()).thenAnswer(
      (_) async => const Right(unit),
    );

    container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(mockUseCase),
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AuthNotifier', () {
    test("l'état initial est AuthState.initial", () {
      expect(
        container.read(authNotifierProvider),
        const AuthState.initial(),
      );
    });

    test('passe par loading puis authenticated après login réussi', () async {
      when(() => mockUseCase.call(tel: tTel, password: tPassword))
          .thenAnswer(
        (_) async => const Right<Failure, UserProfile>(tUser),
      );

      final states = <AuthState>[];
      container.listen(authNotifierProvider, (_, s) => states.add(s));

      await container
          .read(authNotifierProvider.notifier)
          .login(tel: tTel, password: tPassword);

      expect(states, [
        const AuthState.loading(),
        const AuthState.authenticated(tUser),
      ]);
    });

    test('passe en error() en cas de AuthFailure', () async {
      when(() => mockUseCase.call(
          tel: any(named: 'tel'),
          password: any(named: 'password'))).thenAnswer(
        (_) async => const Left<Failure, UserProfile>(
          AuthFailure('Identifiants incorrects', code: FailureCode.invalidCredentials),
        ),
      );

      await container
          .read(authNotifierProvider.notifier)
          .login(tel: tTel, password: tPassword);

      expect(
        container.read(authNotifierProvider),
        const AuthState.error(FailureCode.invalidCredentials),
      );
    });

    test('passe en error() avec message réseau en cas de NetworkFailure',
        () async {
      when(() => mockUseCase.call(
          tel: any(named: 'tel'),
          password: any(named: 'password'))).thenAnswer(
        (_) async => const Left<Failure, UserProfile>(
          NetworkFailure('No connection'),
        ),
      );

      await container
          .read(authNotifierProvider.notifier)
          .login(tel: tTel, password: tPassword);

      expect(
        container.read(authNotifierProvider),
        const AuthState.error(FailureCode.offline),
      );
    });

    test('logout remet l\'état à initial', () async {
      when(() => mockUseCase.call(tel: tTel, password: tPassword))
          .thenAnswer(
        (_) async => const Right<Failure, UserProfile>(tUser),
      );
      await container
          .read(authNotifierProvider.notifier)
          .login(tel: tTel, password: tPassword);

      await container.read(authNotifierProvider.notifier).logout();

      expect(
        container.read(authNotifierProvider),
        const AuthState.initial(),
      );
    });
  });
}
