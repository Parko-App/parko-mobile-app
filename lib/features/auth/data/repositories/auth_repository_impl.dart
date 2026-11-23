import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../../../../core/utils/validators.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    FirebaseAuth? firebaseAuth,
  }) : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required bool termsAccepted,
    String? legajo,
  }) async {
    final studentId = (legajo != null && legajo.trim().isNotEmpty)
        ? legajo.trim()
        : AppValidators.studentIdFromEmail(email);

    final user = await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      studentId: studentId,
      institutionalDomain: AppValidators.institutionalDomainFromEmail(email),
      termsAccepted: termsAccepted,
    );

    try {
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception('Cuenta creada, pero no se pudo iniciar sesión: ${e.message}');
    }

    return user;
  }

  @override
  Future<User> getUserProfile(String token, String firebaseId) async {
    final results = await Future.wait([
      remoteDataSource.getUserProfile(token, firebaseId),
      remoteDataSource.getBalance(token, firebaseId),
    ]);

    final user = results[0] as User;
    final balance = results[1] as double;

    return user.copyWith(balance: balance);
  }

  @override
  Future<double> getBalance(String token, String firebaseId) async {
    return await remoteDataSource.getBalance(token, firebaseId);
  }

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('El legajo, carrera o contraseña son incorrectos');
      }

      return User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? email,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
        case 'invalid-email':
          throw Exception('El legajo, carrera o contraseña son incorrectos');
        case 'user-disabled':
          throw Exception('Esta cuenta ha sido deshabilitada');
        case 'too-many-requests':
          throw Exception('Demasiados intentos fallidos. Intentá más tarde');
        case 'network-request-failed':
          throw Exception('Sin conexión a internet. Verificá tu red');
        default:
          throw Exception(e.message ?? 'El legajo, carrera o contraseña son incorrectos');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No hay una sesión activa de usuario');
    }

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      // Forzamos la renovación inmediata del ID Token para evitar 401s posteriores
      await user.getIdToken(true);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('La contraseña actual es incorrecta');
        case 'weak-password':
          throw Exception('La nueva contraseña es demasiado débil');
        case 'requires-recent-login':
          throw Exception('Por seguridad, cerrá sesión e iniciá nuevamente antes de cambiar tu contraseña');
        case 'network-request-failed':
          throw Exception('Sin conexión a internet. Verificá tu red e intentá de nuevo');
        case 'too-many-requests':
          throw Exception('Demasiados intentos fallidos. Intentá más tarde');
        default:
          throw Exception(e.message ?? 'Error al actualizar la contraseña');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
