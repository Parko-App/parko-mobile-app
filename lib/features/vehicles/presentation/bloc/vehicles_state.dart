import 'package:equatable/equatable.dart';

abstract class VehiclesState extends Equatable {
  const VehiclesState();
  @override
  List<Object?> get props => [];
}

class VehiclesInitial extends VehiclesState {}
class VehiclesLoading extends VehiclesState {}
class VehiclesSuccess extends VehiclesState {}
class VehiclesError extends VehiclesState {
  final String message;
  const VehiclesError(this.message);
  @override
  List<Object?> get props => [message];
}
