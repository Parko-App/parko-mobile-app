import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/vehicle_repository.dart';
import 'vehicles_state.dart';

class VehiclesCubit extends Cubit<VehiclesState> {
  final VehicleRepository _vehicleRepository;
  final firebase.FirebaseAuth _firebaseAuth;

  VehiclesCubit({
    required VehicleRepository vehicleRepository,
    firebase.FirebaseAuth? firebaseAuth,
  })  : _vehicleRepository = vehicleRepository,
        _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        super(VehiclesInitial());

  Future<void> addVehicle({
    required String uuid, // <--- Ahora recibimos el UUID del back
    required String plate,
    required String brand,
    required String model,
  }) async {
    emit(VehiclesLoading());

    try {
      final user = _firebaseAuth.currentUser;
      final token = await user?.getIdToken();

      if (user == null || token == null) {
        throw Exception("No hay una sesión activa de Firebase");
      }

      await _vehicleRepository.addVehicle(
        uuid, // <--- Usamos el UUID real
        token,
        plate.toUpperCase(),
        brand,
        model,
      );

      emit(VehiclesSuccess());
    } catch (e) {
      if(e.toString().contains("El recurso ya existe")){
        emit(VehiclesError("Esa patente ya está registrada"));
        return;
      }
      emit(VehiclesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
