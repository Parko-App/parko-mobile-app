import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// No sabemos si hay alguien logueado (ej: al arrancar la app)
class AuthInitial extends AuthState {}

/// Estado de carga (procesando login o registro)
class AuthLoading extends AuthState {}

/// El usuario está logueado y tenemos sus datos de la entidad User
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// No hay nadie logueado (o cerró sesión)
class Unauthenticated extends AuthState {}

/// Hubo un error en la autenticación
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
