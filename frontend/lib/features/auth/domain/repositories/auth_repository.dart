import "../entities/auth_tokens.dart";

abstract class AuthRepository {
  Future<AuthTokens> login({required String email, required String password});
  Future<void> signup({required String email, required String password});
  Future<void> resendVerificationCode({required String email});
  Future<bool> verifyEmail({required String uid, required String token});
  Future<AuthTokens?> refreshToken(String refreshToken);
}

