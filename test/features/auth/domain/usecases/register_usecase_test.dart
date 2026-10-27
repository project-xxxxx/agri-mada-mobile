import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/features/auth/domain/repositories/auth_repository.dart';
import 'package:agri_mada/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('RegisterUseCase', () {
    late MockAuthRepository repository;
    late RegisterUseCase useCase;

    setUp(() {
      repository = MockAuthRepository();
      useCase = RegisterUseCase(repository);
    });

    test('retourne une ValidationFailure quand un champ est vide', () async {
      final result = await useCase(
        nom: '',
        prenom: 'Jean',
        region: 'Analamanga',
        tel: '0341234567',
        password: '1234',
      );

      expect(
          result, const Left<Failure, Unit>(ValidationFailure('Tous les champs sont requis')));
      verifyZeroInteractions(repository);
    });

    test('delegue au repository quand les champs sont valides', () async {
      when(
        () => repository.register(
          nom: 'Rakoto',
          prenom: 'Jean',
          region: 'Analamanga',
          tel: '0341234567',
          password: '1234',
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase(
        nom: 'Rakoto',
        prenom: 'Jean',
        region: 'Analamanga',
        tel: '0341234567',
        password: '1234',
      );

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => repository.register(
          nom: 'Rakoto',
          prenom: 'Jean',
          region: 'Analamanga',
          tel: '0341234567',
          password: '1234',
        ),
      ).called(1);
    });
  });
}
