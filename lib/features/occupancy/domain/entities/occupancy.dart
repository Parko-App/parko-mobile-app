import 'package:equatable/equatable.dart';

class Occupancy extends Equatable {
  final int totalCapacity;
  final int currentOccupancy;
  final DateTime lastUpdated;

  const Occupancy({
    required this.totalCapacity,
    required this.currentOccupancy,
    required this.lastUpdated,
  });

  int get availableSpaces => totalCapacity - currentOccupancy;
  double get occupancyPercentage => (currentOccupancy / totalCapacity) * 100;
  double get availabilityPercentage => 100 - occupancyPercentage;

  @override
  List<Object?> get props => [totalCapacity, currentOccupancy, lastUpdated];
}
