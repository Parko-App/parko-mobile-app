import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle.dart';

abstract class VehiclesState extends Equatable {
  const VehiclesState();
  @override
  List<Object?> get props => [];
}

class VehiclesInitial extends VehiclesState {}
class VehiclesLoading extends VehiclesState {}

class VehiclesSuccess extends VehiclesState {
  final List<Vehicle> vehicles; // Llevamos la lista para que la UI no se quede vacía
  const VehiclesSuccess(this.vehicles);
  @override
  List<Object?> get props => [vehicles];
}

class VehiclesLoaded extends VehiclesState {
  final List<Vehicle> vehicles;
  const VehiclesLoaded(this.vehicles);
  @override
  List<Object?> get props => [vehicles];
}

class VehiclesError extends VehiclesState {
  final String message;
  const VehiclesError(this.message);
  @override
  List<Object?> get props => [message];
}
