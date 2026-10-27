import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/parcelle_entity.dart';
import '../repositories/journal_repository.dart';

class GetParcellesUseCase {
  const GetParcellesUseCase(this._repository);

  final JournalRepository _repository;

  Future<Either<Failure, List<ParcelleEntity>>> call() {
    return _repository.getParcelles();
  }
}
