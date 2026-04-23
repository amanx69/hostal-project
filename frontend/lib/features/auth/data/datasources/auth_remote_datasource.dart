import "package:dio/dio.dart";

import "../../domain/entities/auth_tokens.dart";
import "../models/auth_tokens_model.dart";

class AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSource(this.dio);

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final res = await dio.post(
      "/api/auth/Login/",
      data: {"email": email, "password": password},
    );
    final model = AuthTokensModel.fromJson(res.data as Map<String, dynamic>);
    return model.toEntity();
  }

  Future<void> signup({
    required String email,
    required String password,
  }) async {
    await dio.post(
      "/api/auth/signup/",
      data: {"email": email, "password": password},
    );
  }

  Future<void> resendCode({required String email}) async {
    await dio.post(
      "/api/auth/resend-code/",
      data: {"email": email},
    );
  }

  Future<bool> verifyEmail({
    required String uid,
    required String token,
  }) async {
    final res = await dio.get("/api/auth/verify-email/$uid/$token/");
    return res.statusCode == 200;
  }

  Future<AuthTokens?> refreshToken(String refreshToken) async {
    final res = await dio.post(
      "/api/auth/refresh/",
      data: {"refresh": refreshToken},
    );
    if (res.data == null) return null;
    final data = Map<String, dynamic>.from(res.data as Map);
    if (!data.containsKey("refresh")) data["refresh"] = refreshToken;
    return AuthTokensModel.fromJson(data).toEntity();
  }
}

