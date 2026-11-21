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
  final bool isLive;
  final bool isRefreshing;
  final bool isStale;

  const OccupancyLoaded(
    this.occupancy, {
    this.isLive = false,
    this.isRefreshing = false,
    this.isStale = false,
  });

  OccupancyLoaded copyWith({
    Occupancy? occupancy,
    bool? isLive,
    bool? isRefreshing,
    bool? isStale,
  }) {
    return OccupancyLoaded(
      occupancy ?? this.occupancy,
      isLive: isLive ?? this.isLive,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isStale: isStale ?? this.isStale,
    );
  }

  @override
  List<Object?> get props => [occupancy, isLive, isRefreshing, isStale];
}

class OccupancyError extends OccupancyState {
  final String message;
  const OccupancyError(this.message);

  @override
  List<Object?> get props => [message];
}
