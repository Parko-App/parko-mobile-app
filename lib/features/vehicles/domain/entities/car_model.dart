import 'package:equatable/equatable.dart';

class CarModel extends Equatable {
  final int id;
  final String name;

  const CarModel({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
