import 'package:equatable/equatable.dart';
import '../../../vehicles/domain/entities/vehicle.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String userName;
  final double balance;
  final List<Vehicle> vehicles; // Ahora usamos la entidad Vehicle
  final List<Map<String, dynamic>> actividad;

  const HomeLoaded({
    required this.userName,
    required this.balance,
    required this.vehicles,
    required this.actividad,
  });

  @override
  List<Object?> get props => [userName, balance, vehicles, actividad];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
