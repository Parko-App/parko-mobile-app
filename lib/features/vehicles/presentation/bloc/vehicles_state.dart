import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle.dart';

abstract class VehiclesState extends Equatable {
  final List<Vehicle> vehicles;

  const VehiclesState({this.vehicles = const []});

  @override
  List<Object?> get props => [vehicles];
}

class VehiclesInitial extends VehiclesState {
  const VehiclesInitial({super.vehicles});
}

class VehiclesLoading extends VehiclesState {
  const VehiclesLoading({super.vehicles});
}

class VehiclesSuccess extends VehiclesState {
  const VehiclesSuccess(List<Vehicle> vehicles) : super(vehicles: vehicles);
}

class VehiclesLoaded extends VehiclesState {
  const VehiclesLoaded(List<Vehicle> vehicles) : super(vehicles: vehicles);
}

class VehiclesError extends VehiclesState {
  final String message;
  const VehiclesError(this.message, {super.vehicles});

  @override
  List<Object?> get props => [message, vehicles];
}
