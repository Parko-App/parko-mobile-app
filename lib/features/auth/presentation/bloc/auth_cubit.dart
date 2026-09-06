import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final firebase.FirebaseAuth _firebaseAuth;
  final AuthRepository _authRepository;

  AuthCubit({
    required this._authRepository,
    firebase.FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      try {
        final token = await firebaseUser.getIdToken();
        final user = await _authRepository.getUserProfile(token!, firebaseUser.uid);
        emit(Authenticated(user));
      } catch (e) {
        await logout();
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final userFromFirebase = await _authRepository.login(email: email, password: password);
      final token = await _firebaseAuth.currentUser?.getIdToken();
      // userFromFirebase.id es el UID de Firebase (ver repositorio)
      final userFull = await _authRepository.getUserProfile(token!, userFromFirebase.id);
      emit(Authenticated(userFull));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      await logout();
    }
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required bool termsAccepted,
    String? legajo,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        termsAccepted: termsAccepted,
        legajo: legajo,
      );
      final token = await _firebaseAuth.currentUser?.getIdToken();
      final firebaseUser = _firebaseAuth.currentUser;
      final userFull = await _authRepository.getUserProfile(token!, firebaseUser!.uid);
      emit(Authenticated(userFull));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Refresca los datos del usuario (saldo incluido) desde el backend
  Future<void> refreshProfile() async {
    final currentState = state;
    final firebaseUser = _firebaseAuth.currentUser;
    
    if (currentState is Authenticated && firebaseUser != null) {
      try {
        final token = await firebaseUser.getIdToken();
        if (token == null) return;

        final updatedUser = await _authRepository.getUserProfile(token, firebaseUser.uid);
        emit(Authenticated(updatedUser));
      } catch (_) {
        // En refrescos automáticos no bloqueamos la UI
      }
    }
  }

  /// Cierre de sesión
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    emit(Unauthenticated());
  }

  /// Preferencia local de notificaciones
  void toggleNotifications(bool enabled) {
    final currentState = state;
    if (currentState is Authenticated) {
      emit(Authenticated(currentState.user.copyWith(notificationsEnabled: enabled)));
    }
  }

  /// Actualiza el balance manualmente si fuera necesario
  void updateBalance(double newBalance) {
    final currentState = state;
    if (currentState is Authenticated) {
      emit(Authenticated(currentState.user.copyWith(balance: newBalance)));
    }
  }
}
