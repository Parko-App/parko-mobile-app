import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final firebase.FirebaseAuth _firebaseAuth;
  final AuthRepository _authRepository;

  AuthCubit({
    required AuthRepository authRepository,
    firebase.FirebaseAuth? firebaseAuth,
  })  : _authRepository = authRepository,
        _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      try {
        final token = await firebaseUser.getIdToken();
        if (token != null) {
          final user = await _authRepository.getUserProfile(token, firebaseUser.uid);
          emit(Authenticated(user));
          return;
        }
      } catch (e) {
        await logout();
        emit(Unauthenticated());
        return;
      }
    }
    emit(Unauthenticated());
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final userFromFirebase = await _authRepository.login(email: email, password: password);
      final firebaseUser = _firebaseAuth.currentUser;
      final token = await firebaseUser?.getIdToken();

      if (firebaseUser != null && token != null) {
        try {
          final userFull = await _authRepository.getUserProfile(token, firebaseUser.uid);
          emit(Authenticated(userFull));
          return;
        } catch (_) {}
      }

      emit(Authenticated(userFromFirebase));
    } catch (e) {
      final rawError = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(rawError));
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
      final registeredUser = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        termsAccepted: termsAccepted,
        legajo: legajo,
      );

      final firebaseUser = _firebaseAuth.currentUser;
      final token = await firebaseUser?.getIdToken();

      if (firebaseUser != null && token != null) {
        try {
          final userFull = await _authRepository.getUserProfile(token, firebaseUser.uid);
          emit(Authenticated(userFull));
          return;
        } catch (_) {
          // Si falla la llamada al backend para obtener el perfil extendido, usamos el usuario registrado
        }
      }

      emit(Authenticated(registeredUser));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Cambia la contraseña del usuario autenticado
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
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
