import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/occupancy.dart';
import 'occupancy_state.dart';

class OccupancyCubit extends Cubit<OccupancyState> {
  Timer? _pollingTimer;
  final _random = Random();
  int _currentCount = 120;

  OccupancyCubit() : super(OccupancyInitial());

  Future<void> fetchOccupancy() async {
    if (state is! OccupancyLoaded) {
      emit(OccupancyLoading());
    }

    try {
      await Future.delayed(const Duration(milliseconds: 400));

      if (_currentCount == 0) _currentCount = 120;
      _emitNewState();
    } catch (e) {
      emit(const OccupancyError("No se pudo cargar la ocupación"));
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final change = _random.nextBool();
      if(change == true){
        _currentCount++;
      }else{
        _currentCount--;
      }
      _emitNewState();
      print("Se hizo");
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void startSimulation() => startPolling();
  void stopSimulation() => stopPolling();

  // Metodo para actualizar la ocupacion en algun momento pai
  void updateOccupancy(int newCount) {
    _currentCount = newCount;
    _emitNewState();
  }

  void _emitNewState() {
    final mockOccupancy = Occupancy(
      totalCapacity: 300,
      currentOccupancy: _currentCount,
      lastUpdated: DateTime.now(),
    );
    emit(OccupancyLoaded(mockOccupancy));
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
