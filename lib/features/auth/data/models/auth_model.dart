import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_entity.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
class AuthModel with _$AuthModel {
  const factory AuthModel({
    required String accessToken,
    required String tokenType,
  }) = _AuthModel;

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);
}

extension AuthModelMapper on AuthModel {
  AuthToken toEntity() => AuthToken(
        accessToken: accessToken,
        tokenType: tokenType,
      );
}
