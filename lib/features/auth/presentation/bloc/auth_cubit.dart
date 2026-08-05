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
    if (firebaseUser != null) {
      try {
        final token = await firebaseUser.getIdToken();
        // Buscamos el perfil real en el backend usando el UID de Firebase
        final user = await _authRepository.getUserProfile(token!, firebaseUser.uid);
        emit(Authenticated(user));
      } catch (e) {
        // Si falla el back, por seguridad deslogueamos de Firebase
        await logout();
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  /// PROCESO DE LOGIN UNIFICADO
  Future<void> login(String email, String password) async {
    // Emitimos carga para resetear cualquier error previo y disparar el listener
    emit(AuthLoading());
    
    try {
      // 1. Logueamos en Firebase a través del repositorio
      final userFromFirebase = await _authRepository.login(email: email, password: password);
      
      // 2. Buscamos el token fresco
      final token = await _firebaseAuth.currentUser?.getIdToken();
      
      // 3. Traemos el perfil del backend
      final userFull = await _authRepository.getUserProfile(token!, userFromFirebase.id);
      
      // 4. Si todo salió bien, emitimos el éxito
      emit(Authenticated(userFull));
    } catch (e) {
      // Limpiamos el mensaje de error del backend
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
      // 1. Registramos en el repositorio (Back + Firebase)
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        termsAccepted: termsAccepted,
        legajo: legajo,
      );

      // 2. Emitimos el estado de autenticado con el nuevo usuario
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Cierre de sesión persistente
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    emit(Unauthenticated());
  }

  /// Mantenemos este por compatibilidad si se usa en otros lados, 
  /// pero la lógica pro ahora va en registerUser
  void register(User user) {
    emit(Authenticated(user));
  }
}
