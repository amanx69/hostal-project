import "../entities/auth_tokens.dart";
import "../repositories/auth_repository.dart";

class RefreshTokenUseCase {
  final AuthRepository repository;
  RefreshTokenUseCase(this.repository);

  Future<AuthTokens?> call(String refreshToken) {
    return repository.refreshToken(refreshToken);
  }
}

