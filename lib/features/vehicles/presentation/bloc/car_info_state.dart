import 'package:equatable/equatable.dart';
import '../../domain/entities/car_brand.dart';
import '../../domain/entities/car_model.dart';

class CarInfoState extends Equatable {
  final List<CarBrand> brands;
  final List<CarModel> models;
  final bool isLoadingBrands;
  final bool isLoadingModels;
  final String? errorMessage;

  const CarInfoState({
    this.brands = const [],
    this.models = const [],
    this.isLoadingBrands = false,
    this.isLoadingModels = false,
    this.errorMessage,
  });

  CarInfoState copyWith({
    List<CarBrand>? brands,
    List<CarModel>? models,
    bool? isLoadingBrands,
    bool? isLoadingModels,
    String? errorMessage,
  }) {
    return CarInfoState(
      brands: brands ?? this.brands,
      models: models ?? this.models,
      isLoadingBrands: isLoadingBrands ?? this.isLoadingBrands,
      isLoadingModels: isLoadingModels ?? this.isLoadingModels,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [brands, models, isLoadingBrands, isLoadingModels, errorMessage];
}
