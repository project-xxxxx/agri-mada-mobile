import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthEntity>> call({
    required String tel,
    required String password,
  }) {
    if (tel.isEmpty || password.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Numero et mot de passe requis')),
      );
    }
    return _repository.login(tel: tel, password: password);
  }
}
