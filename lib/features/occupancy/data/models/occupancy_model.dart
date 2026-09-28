import '../../domain/entities/occupancy.dart';

class OccupancyModel extends Occupancy {
  const OccupancyModel({
    required super.totalCapacity,
    required super.currentOccupancy,
    required super.lastUpdated,
  });

  factory OccupancyModel.fromJson(Map<String, dynamic> json) {
    return OccupancyModel(
      totalCapacity: json['totalCapacity'] ?? json['capacity'] ?? 300,
      currentOccupancy: json['currentOccupancy'] ?? json['occupied'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCapacity': totalCapacity,
      'currentOccupancy': currentOccupancy,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
