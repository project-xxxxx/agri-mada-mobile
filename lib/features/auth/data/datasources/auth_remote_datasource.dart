import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/auth_model.dart';

part 'auth_remote_datasource.g.dart';

@RestApi()
abstract class AuthRemoteDatasource {
  factory AuthRemoteDatasource(Dio dio, {String baseUrl}) =
      _AuthRemoteDatasource;

  @POST(ApiConstants.register)
  Future<dynamic> register(
    @Body() Map<String, dynamic> payload,
  );

  @FormUrlEncoded()
  @POST(ApiConstants.login)
  Future<AuthModel> login(
    @Field('username') String username,
    @Field('password') String password,
  );

  @POST(ApiConstants.logout)
  Future<void> logout(
    @Body() Map<String, dynamic> payload,
  );

  @GET(ApiConstants.me)
  Future<dynamic> getMe(
    @Header('Authorization') String authorization,
  );

  @POST(ApiConstants.forgotPassword)
  Future<dynamic> forgotPassword(
    @Body() Map<String, dynamic> payload,
  );
}
