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
      final credential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final firebaseUser = credential.user!;

      return User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? email,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'No se pudo iniciar sesión');
    }
  }
}
