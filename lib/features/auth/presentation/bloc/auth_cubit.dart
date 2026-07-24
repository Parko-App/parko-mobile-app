import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
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

  /// Este método chequea si ya hay una sesión activa al abrir la app.
  Future<void> checkAuthStatus() async {
    final firebaseUser = _firebaseAuth.currentUser;
    String UUID = 'asd';
    if (firebaseUser != null) {
      try {
        // Buscamos el perfil real en el backend
        /// esto es para poder acceder al usuario en el back hasta solucionar lo del token
        if(firebaseUser.email == "admin@admin.frc.utn.edu.ar"){
          UUID = '8576f95b-fd15-4691-aef7-469d231ed8b6';
        }
        final user = await _authRepository.getUserProfile(UUID);
        emit(Authenticated(user));
      } catch (e) {
        // Si el back falla, emitimos error o un usuario básico
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  /// Cuando el login es exitoso, actualizamos el estado global.
  /// Voy a hardcodear con el UUID hasta ver bien como es esto
  Future<void> login(String uuid) async {
    try {
      // Pedimos el perfil al backend después de loguear en Firebase
      final user = await _authRepository.getUserProfile(uuid);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError("Sesión iniciada pero no se encontró el perfil en Parko"));
    }
  }

  /// Cerrar sesión limpia el estado global.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    emit(Unauthenticated());
  }
}
