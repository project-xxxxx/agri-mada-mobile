import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String tel,
  }) {
    if (tel.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Le numero de telephone est requis')),
      );
    }

    return _repository.forgotPassword(tel: tel.trim());
  }
}
