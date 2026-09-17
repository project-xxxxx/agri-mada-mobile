import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/parcelle_entity.dart';

abstract interface class JournalRepository {
  Future<Either<Failure, List<ParcelleEntity>>> getParcelles();

  Future<Either<Failure, Unit>> saveParcelle(ParcelleEntity parcelle);

  Future<Either<Failure, Unit>> deleteParcelle(String id);
}
