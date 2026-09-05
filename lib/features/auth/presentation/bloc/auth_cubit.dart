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

      final userFull = await _authRepository.getUserProfile(token!, userFromFirebase.id);

      emit(Authenticated(userFull));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      logout();
    }
  }

  /// PROCESO DE REGISTRO UNIFICADO
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

      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    emit(Unauthenticated());
  }
/*
  void register(User user) {
    emit(Authenticated(user));
  }
*/

  void toggleNotifications(bool enabled) {
    final currentState = state;
    if (currentState is Authenticated) {
      final updatedUser = User(
        id: currentState.user.id,
        name: currentState.user.name,
        email: currentState.user.email,
        legajo: currentState.user.legajo,
        balance: currentState.user.balance,
        notificationsEnabled: enabled,
      );
      emit(Authenticated(updatedUser));
    }
  }

  void updateBalance(double newBalance) {
    final currentState = state;
    if (currentState is Authenticated) {
      final updatedUser = User(
        id: currentState.user.id,
        name: currentState.user.name,
        email: currentState.user.email,
        legajo: currentState.user.legajo,
        balance: newBalance, // Nuevo saldo
        notificationsEnabled: currentState.user.notificationsEnabled,
      );
      emit(Authenticated(updatedUser));
    }
  }
}
