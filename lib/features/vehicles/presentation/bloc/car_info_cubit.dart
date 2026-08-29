import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/car_info_remote_datasource.dart';
import 'car_info_state.dart';

class CarInfoCubit extends Cubit<CarInfoState> {
  final CarInfoRemoteDataSource _dataSource;

  CarInfoCubit({required CarInfoRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const CarInfoState());

  Future<void> fetchBrands() async {
    emit(state.copyWith(isLoadingBrands: true, errorMessage: null));
    try {
      final brands = await _dataSource.getBrands();
      emit(state.copyWith(brands: brands, isLoadingBrands: false));
    } catch (e) {
      emit(state.copyWith(isLoadingBrands: false, errorMessage: "No se pudieron cargar las marcas"));
    }
  }

  Future<void> fetchModels(int brandId) async {
    emit(state.copyWith(isLoadingModels: true, models: [], errorMessage: null));
    try {
      final models = await _dataSource.getModels(brandId);
      emit(state.copyWith(models: models, isLoadingModels: false));
    } catch (e) {
      emit(state.copyWith(isLoadingModels: false, errorMessage: "No se pudieron cargar los modelos"));
    }
  }
}
