import '../../domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.plate,
    required super.brand,
    required super.model,
    required super.active,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      plate: json['plate'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate': plate,
      'brand': brand,
      'model': model,
      'active': active,
    };
  }
}
