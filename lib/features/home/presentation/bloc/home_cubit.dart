import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  /// Carga los datos de actividad reciente
  Future<void> fetchHomeData(String userId, [String? token]) async {
    emit(HomeLoading());
    try {
      final actividad = await _getActividadMock();
      emit(HomeLoaded(actividad: actividad));
    } catch (e) {
      emit(const HomeError("No se pudo cargar la actividad reciente"));
    }
  }

  Future<List<Map<String, dynamic>>> _getActividadMock() async {
    return [
      {'title': 'Estacionamiento UTN', 'date': 'Hoy', 'time': '10:30 AM', 'amount': '1.200', 'type': 'ingreso'},
      {'title': 'Carga de saldo', 'date': 'Ayer', 'time': '04:15 PM', 'amount': '5.000', 'type': 'carga'},
      {'title': 'Estacionamiento UTN', 'date': '15 Ago', 'time': '08:45 AM', 'amount': '1.200', 'type': 'ingreso'},
    ];
  }
}
