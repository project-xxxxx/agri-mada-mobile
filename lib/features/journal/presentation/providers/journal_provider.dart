// Providers Riverpod pour la gestion du journal agricole (Isar)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/local_db/models/diagnostic_local.dart';
import '../../../../core/local_db/models/parcelle_local.dart';
import '../../data/repositories/parcelle_local_repository.dart';
import '../../data/services/export_service.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/parcelle_entity.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/usecases/export_journal_usecase.dart';
import '../../domain/usecases/get_parcelles_usecase.dart';
import '../../../scan/presentation/providers/scan_provider.dart' show diagnosticRepositoryProvider;

/// Accès au repository des parcelles
final parcelleRepositoryProvider = Provider<ParcelleLocalRepository>(
  (_) => ParcelleLocalRepository(),
);

/// Contrat domain du journal
final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => ref.watch(parcelleRepositoryProvider),
);

/// Use case de lecture des parcelles
final getParcellesUseCaseProvider = Provider<GetParcellesUseCase>(
  (ref) => GetParcellesUseCase(ref.watch(journalRepositoryProvider)),
);

final exportServiceProvider = Provider<ExportService>(
  (_) => ExportService(),
);

// Réutilise diagnosticRepositoryProvider centralisé depuis scan_provider

final exportJournalUseCaseProvider = Provider<ExportJournalUseCase>(
  (ref) => ExportJournalUseCase(
    diagnosticRepository: ref.watch(diagnosticRepositoryProvider),
    parcelleRepository: ref.watch(parcelleRepositoryProvider),
    exportService: ref.watch(exportServiceProvider),
  ),
);

/// Journal agricole complet avec statut de santé de chaque parcelle
/// Journal agricole complet avec statut de santé de chaque parcelle
final journalAgricoleProvider =
    FutureProvider<List<JournalEntry>>((ref) async {
  return ref.read(parcelleRepositoryProvider).getJournalAgricole();
});

/// Liste simple de toutes les parcelles
final parcellesProvider = FutureProvider<List<ParcelleLocal>>((ref) async {
  final result = await ref.read(getParcellesUseCaseProvider).call();
  return result.fold(
    (_) => <ParcelleLocal>[],
    (parcelles) => parcelles
        .map(
          (parcelle) => ParcelleLocal()
            ..id = int.tryParse(parcelle.id) ?? 0
            ..nomParcelle = parcelle.nom
            ..surface = parcelle.surface
            ..createdAt = parcelle.lastDiagnosticDate ?? DateTime.now()
            ..isSynced = parcelle.isSynced,
        )
        .toList(),
  );
});

/// Liste complète de l'historique des diagnostics
final diagnosticsHistoryProvider = FutureProvider<List<DiagnosticLocal>>((ref) async {
  return ref.read(diagnosticRepositoryProvider).getAllDiagnostics();
});

/// Notifier pour les actions de création / mise à jour des parcelles
class ParcelleNotifier extends StateNotifier<AsyncValue<void>> {
  ParcelleNotifier(this._repo) : super(const AsyncValue.data(null));

  final ParcelleLocalRepository _repo;

  Future<ParcelleLocal?> createParcelle({
    required String nom,
    String? description,
    double? surface,
    double? latitude,
    double? longitude,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repo.saveParcelle(
        ParcelleEntity(
          id: '0',
          nom: nom,
          surface: surface,
          culture: 'Riz',
          isSynced: false,
        ),
      );

      return result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
          return null;
        },
        (_) async {
          final parcelles = await _repo.getAllParcelles();
          parcelles.sort((a, b) => a.id.compareTo(b.id));
          final parcelle = parcelles.isEmpty ? null : parcelles.last;
          state = const AsyncValue.data(null);
          return parcelle;
        },
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final parcelleNotifierProvider =
    StateNotifierProvider<ParcelleNotifier, AsyncValue<void>>(
  (ref) => ParcelleNotifier(ref.watch(parcelleRepositoryProvider)),
);
