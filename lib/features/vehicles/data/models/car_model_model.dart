import '../../domain/entities/car_model.dart';

class CarModelModel extends CarModel {
  const CarModelModel({required super.id, required super.name});

  factory CarModelModel.fromJson(Map<String, dynamic> json) {
    return CarModelModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
