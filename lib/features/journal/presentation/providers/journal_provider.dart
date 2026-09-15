// Providers Riverpod pour la gestion du journal agricole (Isar)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/local_db/models/diagnostic_local.dart';
import '../../../../core/local_db/models/parcelle_local.dart';
import '../../data/repositories/parcelle_local_repository.dart';
import '../../data/services/export_service.dart';
import '../../domain/entities/journal_entry.dart';
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
final journalAgricoleProvider =
    FutureProvider<List<JournalEntry>>((ref) async {
  return ref.read(parcelleRepositoryProvider).getJournalAgricole();
});

/// Liste de toutes les parcelles, lues directement dans Isar : photo,
/// emplacement et date de création ne sont plus perdus (tâche P1.6).
final parcellesProvider = FutureProvider<List<ParcelleLocal>>((ref) {
  return ref.read(parcelleRepositoryProvider).getAllParcelles();
});

/// Liste complète de l'historique des diagnostics
final diagnosticsHistoryProvider = FutureProvider<List<DiagnosticLocal>>((ref) async {
  return ref.read(diagnosticRepositoryProvider).getAllDiagnostics();
});

/// Notifier pour les actions de création / mise à jour des parcelles
class ParcelleNotifier extends StateNotifier<AsyncValue<void>> {
  ParcelleNotifier(this._repo) : super(const AsyncValue.data(null));

  final ParcelleLocalRepository _repo;

  /// Crée une parcelle et renvoie celle qui vient d'être enregistrée,
  /// ou null en cas d'échec.
  Future<ParcelleLocal?> createParcelle({
    required String nom,
    String? description,
    String? culture,
    double? surface,
    double? latitude,
    double? longitude,
    String? photoPath,
  }) async {
    state = const AsyncValue.loading();
    try {
      final parcelle = await _repo.createParcelle(
        nomParcelle: nom,
        description: description,
        culture: culture ?? 'Riz',
        surface: surface,
        latitude: latitude,
        longitude: longitude,
        photoPath: photoPath,
      );
      state = const AsyncValue.data(null);
      return parcelle;
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
