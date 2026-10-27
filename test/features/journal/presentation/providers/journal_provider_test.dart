import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/local_db/models/parcelle_local.dart';
import 'package:agri_mada/features/journal/data/repositories/parcelle_local_repository.dart';
import 'package:agri_mada/features/journal/presentation/providers/journal_provider.dart';
import 'package:agri_mada/features/journal/domain/entities/journal_entry.dart';

class MockParcelleLocalRepository extends Mock
    implements ParcelleLocalRepository {}

void main() {
  late ProviderContainer container;
  late MockParcelleLocalRepository mockRepository;

  setUp(() {
    mockRepository = MockParcelleLocalRepository();
    container = ProviderContainer(
      overrides: [
        parcelleRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('journalAgricoleProvider', () {
    test('chargement initial -> loading()', () {
      when(() => mockRepository.getJournalAgricole()).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return <JournalEntry>[];
        },
      );

      final value = container.read(journalAgricoleProvider);

      expect(value, const AsyncLoading<List<JournalEntry>>());
    });

    test('liste vide -> empty', () async {
      when(() => mockRepository.getJournalAgricole()).thenAnswer(
        (_) async => <JournalEntry>[],
      );

      final result = await container.read(journalAgricoleProvider.future);

      expect(result, isEmpty);
    });

    test('liste non vide -> loaded(parcelles)', () async {
      final parcelle = ParcelleLocal()
        ..id = 1
        ..nomParcelle = 'Riziere Centre'
        ..createdAt = DateTime(2026, 1, 1);

      when(() => mockRepository.getJournalAgricole()).thenAnswer(
        (_) async => <JournalEntry>[
          JournalEntry(
            parcelle: parcelle,
            nbDiagnostics: 1,
            derniereMaladie: 'Brown spot',
            statut: 'malade',
          ),
        ],
      );

      final result = await container.read(journalAgricoleProvider.future);

      expect(result, hasLength(1));
      expect(result.first.parcelle.nomParcelle, 'Riziere Centre');
    });

    test('erreur Isar -> error(message)', () async {
      when(() => mockRepository.getJournalAgricole()).thenThrow(
        Exception('Isar indisponible'),
      );

      await expectLater(
        container.read(journalAgricoleProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
