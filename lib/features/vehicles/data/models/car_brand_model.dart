import '../../domain/entities/car_brand.dart';

class CarBrandModel extends CarBrand {
  const CarBrandModel({required super.id, required super.name});

  factory CarBrandModel.fromJson(Map<String, dynamic> json) {
    return CarBrandModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
