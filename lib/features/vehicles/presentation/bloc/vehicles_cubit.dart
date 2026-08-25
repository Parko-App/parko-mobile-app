import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/vehicle_repository.dart';
import 'vehicles_state.dart';

class VehiclesCubit extends Cubit<VehiclesState> {
  final VehicleRepository _vehicleRepository;
  final firebase.FirebaseAuth _firebaseAuth;

  VehiclesCubit({
    required this._vehicleRepository,
    firebase.FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        super(VehiclesInitial());

  /// Obtiene la lista de vehículos del usuario
  Future<void> fetchVehicles(String uuid) async {
    emit(VehiclesLoading());
    try {
      final token = await _firebaseAuth.currentUser?.getIdToken();
      if (token == null) throw Exception("Sesión expirada");

      final vehicles = await _vehicleRepository.getUserVehicles(uuid, token);
      emit(VehiclesLoaded(vehicles));
    } catch (e) {
      emit(VehiclesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Registra un nuevo vehículo
  Future<void> addVehicle({
    required String uuid,
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
        uuid,
        token,
        plate.toUpperCase(),
        brand,
        model,
      );

      final vehicles = await _vehicleRepository.getUserVehicles(uuid, token);

      emit(VehiclesSuccess(vehicles));
    } catch (e) {
      if(e.toString().contains("El recurso ya existe")){
        emit(VehiclesError("Esa patente ya está registrada"));
        return;
      }
      emit(VehiclesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Elimina un vehículo
  Future<void> deleteVehicle(String vehicleId, String uuid) async {
    emit(VehiclesLoading());
    try {
      final token = await _firebaseAuth.currentUser?.getIdToken();
      if (token == null) throw Exception("Sesión expirada");

      await _vehicleRepository.deleteVehicle(vehicleId, token);
      
      // Después de eliminar, refrescamos la lista
      await fetchVehicles(uuid);
    } catch (e) {
      emit(VehiclesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
