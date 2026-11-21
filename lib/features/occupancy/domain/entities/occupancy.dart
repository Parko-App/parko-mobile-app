import 'package:equatable/equatable.dart';

class Occupancy extends Equatable {
  final int occupied;
  final int capacity;
  final int available;
  final DateTime lastUpdated;

  const Occupancy({
    this.occupied = 0,
    this.capacity = 100,
    this.available = 100,
    required this.lastUpdated,
  });

  // Getters para mantener compatibilidad total con widgets existentes (OccupancyChart, LiveCarAnimation, etc.)
  int get availableSpaces => available;
  int get currentOccupancy => occupied;
  int get totalCapacity => capacity;
  double get occupancyPercentage => capacity > 0 ? (occupied / capacity) * 100 : 0.0;
  double get availabilityPercentage => 100 - occupancyPercentage;

  @override
  List<Object?> get props => [occupied, capacity, available, lastUpdated];
}
