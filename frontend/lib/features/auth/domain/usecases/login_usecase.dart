import "../entities/auth_tokens.dart";
import "../repositories/auth_repository.dart";

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<AuthTokens> call(String email, String password) {
    return repository.login(email: email, password: password);
  }
}

