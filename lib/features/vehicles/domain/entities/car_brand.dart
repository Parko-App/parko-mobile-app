import 'package:equatable/equatable.dart';

class CarBrand extends Equatable {
  final int id;
  final String name;

  const CarBrand({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
