import '../../domain/entities/occupancy.dart';

class OccupancyModel extends Occupancy {
  const OccupancyModel({
    super.occupied,
    super.capacity,
    super.available,
    required super.lastUpdated,
  });

  factory OccupancyModel.fromJson(Map<String, dynamic> json) {
    final int occupied = json['occupied'] ?? json['currentOccupancy'] ?? 0;
    final int capacity = json['capacity'] ?? json['totalCapacity'] ?? 100;
    final int available = json['available'] ?? (capacity - occupied);
    final DateTime lastUpdated = json['lastUpdated'] != null
        ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
        : DateTime.now();

    return OccupancyModel(
      occupied: occupied,
      capacity: capacity,
      available: available,
      lastUpdated: lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'occupied': occupied,
      'capacity': capacity,
      'available': available,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
