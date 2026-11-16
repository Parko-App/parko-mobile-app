import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String plate;
  final String brand;
  final String model;
  final bool active;

  const Vehicle({
    required this.id,
    required this.plate,
    required this.brand,
    required this.model,
    required this.active,
  });

  @override
  List<Object?> get props => [id, plate, brand, model, active];
}
