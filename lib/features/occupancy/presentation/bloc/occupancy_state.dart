import 'package:equatable/equatable.dart';
import '../../domain/entities/occupancy.dart';

abstract class OccupancyState extends Equatable {
  const OccupancyState();
  @override
  List<Object?> get props => [];
}

class OccupancyInitial extends OccupancyState {}
class OccupancyLoading extends OccupancyState {}

class OccupancyLoaded extends OccupancyState {
  final Occupancy occupancy;
  const OccupancyLoaded(this.occupancy);
  @override
  List<Object?> get props => [occupancy];
}

class OccupancyError extends OccupancyState {
  final String message;
  const OccupancyError(this.message);
  @override
  List<Object?> get props => [message];
}
