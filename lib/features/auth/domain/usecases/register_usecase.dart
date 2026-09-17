import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String nom,
    required String prenom,
    required String region,
    required String tel,
    required String password,
  }) {
    if (nom.isEmpty || prenom.isEmpty || region.isEmpty || tel.isEmpty || password.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Tous les champs sont requis')),
      );
    }

    return _repository.register(
      nom: nom,
      prenom: prenom,
      region: region,
      tel: tel,
      password: password,
    );
  }
}
