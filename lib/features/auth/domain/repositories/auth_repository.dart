import '../entities/user.dart';

abstract class AuthRepository {
  /// Intenta registrar un nuevo usuario en el sistema.
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required bool termsAccepted,
    String? legajo,
  });

  /// Intenta iniciar sesión.
  Future<User> login({
    required String email,
    required String password,
  });
}
