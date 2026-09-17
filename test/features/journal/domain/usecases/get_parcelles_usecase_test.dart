import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/features/journal/domain/entities/parcelle_entity.dart';
import 'package:agri_mada/features/journal/domain/repositories/journal_repository.dart';
import 'package:agri_mada/features/journal/domain/usecases/get_parcelles_usecase.dart';

class MockJournalRepository extends Mock implements JournalRepository {}

void main() {
  late MockJournalRepository repository;
  late GetParcellesUseCase useCase;

  const tParcelles = [
    ParcelleEntity(
      id: '1',
      nom: 'Riziere Nord',
      surface: 1.2,
      culture: 'Riz',
      isSynced: false,
    ),
    ParcelleEntity(
      id: '2',
      nom: 'Riziere Sud',
      surface: 0.8,
      culture: 'Riz',
      isSynced: true,
    ),
  ];

  setUp(() {
    repository = MockJournalRepository();
    useCase = GetParcellesUseCase(repository);
  });

  group('GetParcellesUseCase', () {
    test('succes -> retourne une liste de ParcelleEntity', () async {
      // Arrange
      when(() => repository.getParcelles()).thenAnswer(
        (_) async => const Right<Failure, List<ParcelleEntity>>(tParcelles),
      );

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right<Failure, List<ParcelleEntity>>(tParcelles));
      verify(() => repository.getParcelles()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('erreur Isar -> retourne une Failure', () async {
      // Arrange
      when(() => repository.getParcelles()).thenAnswer(
        (_) async => const Left(CacheFailure('Isar indisponible')),
      );

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Expected CacheFailure'),
      );
      verify(() => repository.getParcelles()).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
