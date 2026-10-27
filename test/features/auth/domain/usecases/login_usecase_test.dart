import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/features/auth/domain/entities/auth_entity.dart';
import 'package:agri_mada/features/auth/domain/repositories/auth_repository.dart';
import 'package:agri_mada/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepo;

  const tTel = '0341234567';
  const tPassword = 'password123';
  const UserProfile tUser = UserProfile(
    userId: 'user-001',
    email: 'user@agrimada.mg',
    phoneNumber: tTel,
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = LoginUseCase(mockRepo);
  });

  group('LoginUseCase', () {
    test('retourne un AuthEntity quand le repository répond avec succès',
        () async {
      when(() => mockRepo.login(tel: tTel, password: tPassword)).thenAnswer(
        (_) async => const Right<Failure, UserProfile>(tUser),
      );

      final result = await useCase(tel: tTel, password: tPassword);

      expect(result, const Right<Failure, UserProfile>(tUser));
      verify(() => mockRepo.login(tel: tTel, password: tPassword)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('retourne un NetworkFailure quand le réseau est indisponible',
        () async {
      when(() => mockRepo.login(
          tel: any(named: 'tel'),
          password: any(named: 'password'))).thenAnswer(
        (_) async => const Left<Failure, UserProfile>(
          NetworkFailure('No connection'),
        ),
      );

      final result = await useCase(tel: tTel, password: tPassword);

      expect(
        result,
        const Left<Failure, UserProfile>(NetworkFailure('No connection')),
      );
    });

    test('retourne un AuthFailure quand les identifiants sont incorrects',
        () async {
      when(() => mockRepo.login(
              tel: any(named: 'tel'), password: any(named: 'password')))
          .thenAnswer(
              (_) async => const Left(AuthFailure('Identifiants incorrects')));

      final result = await useCase(tel: tTel, password: tPassword);

      result.fold(
        (f) => expect(f, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('retourne une ValidationFailure sans appel réseau si tel vide',
        () async {
      final result = await useCase(tel: '', password: tPassword);

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
      verifyNever(
        () => mockRepo.login(
            tel: any(named: 'tel'), password: any(named: 'password')),
      );
    });

    test(
        'retourne une ValidationFailure sans appel réseau si mot de passe vide',
        () async {
      final result = await useCase(tel: tTel, password: '');

      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
      verifyNever(
        () => mockRepo.login(
            tel: any(named: 'tel'), password: any(named: 'password')),
      );
    });
  });
}
