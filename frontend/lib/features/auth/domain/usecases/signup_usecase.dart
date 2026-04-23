import "../repositories/auth_repository.dart";

class SignupUseCase {
  final AuthRepository repository;
  SignupUseCase(this.repository);

  Future<void> call(String email, String password) {
    return repository.signup(email: email, password: password);
  }
}

