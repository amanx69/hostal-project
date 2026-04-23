import "package:dio/dio.dart";

import "../../../../core/network/dio_client.dart";
import "../../domain/entities/auth_tokens.dart";
import "../../domain/repositories/auth_repository.dart";
import "../datasources/auth_remote_datasource.dart";

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      return await remote.login(email: email, password: password);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> signup({required String email, required String password}) async {
    try {
      await remote.signup(email: email, password: password);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> resendVerificationCode({required String email}) async {
    try {
      await remote.resendCode(email: email);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<bool> verifyEmail({required String uid, required String token}) async {
    try {
      return await remote.verifyEmail(uid: uid, token: token);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AuthTokens?> refreshToken(String refreshToken) async {
    try {
      return await remote.refreshToken(refreshToken);
    } on DioException catch (_) {
      return null;
    }
  }
}

