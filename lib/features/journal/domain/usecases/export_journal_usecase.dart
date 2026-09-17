import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../journal/data/repositories/parcelle_local_repository.dart';
import '../../../scan/data/repositories/session_local_repository.dart';
import '../../data/services/export_service.dart';

enum ExportFormat { csv, pdf }

class ExportJournalUseCase {
  ExportJournalUseCase({
    required SessionLocalRepository sessionRepository,
    required ParcelleLocalRepository parcelleRepository,
    required ExportService exportService,
  })  : _sessionRepository = sessionRepository,
        _parcelleRepository = parcelleRepository,
        _exportService = exportService;

  final SessionLocalRepository _sessionRepository;
  final ParcelleLocalRepository _parcelleRepository;
  final ExportService _exportService;

  Future<Either<Failure, String>> call({
    int? parcelleId,
    required ExportFormat format,
    required ExportStrings strings,
  }) async {
    try {
      final resultats = await _sessionRepository.resultats(parcelleLocalId: parcelleId);
      if (resultats.isEmpty) {
        return const Left(CacheFailure('Aucun diagnostic à exporter'));
      }

      final parcelles = await _parcelleRepository.getAllParcelles();
      final parcellesById = {
        for (final parcelle in parcelles) parcelle.id: parcelle,
      };

      final ordonnes = resultats.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final path = switch (format) {
        ExportFormat.csv => await _exportService.exportCsv(
            resultats: ordonnes,
            parcellesById: parcellesById,
            parcelleId: parcelleId,
            strings: strings,
          ),
        ExportFormat.pdf => await _exportService.exportPdf(
            resultats: ordonnes,
            parcellesById: parcellesById,
            parcelleId: parcelleId,
            strings: strings,
          ),
      };

      return Right(path);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
