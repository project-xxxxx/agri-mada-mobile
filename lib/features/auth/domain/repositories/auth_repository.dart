import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/auth_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, Unit>> register({
    required String nom,
    required String prenom,
    required String region,
    required String tel,
    required String password,
  });

  Future<Either<Failure, AuthEntity>> login({
    required String tel,
    required String password,
  });

  Future<Either<Failure, Unit>> forgotPassword({
    required String tel,
  });

  Future<Either<Failure, Unit>> logout();
}
