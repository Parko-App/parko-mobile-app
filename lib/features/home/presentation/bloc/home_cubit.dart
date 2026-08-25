import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/domain/repositories/vehicle_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AuthRepository _authRepository;
  final VehicleRepository _vehicleRepository;
  final firebase.FirebaseAuth _firebaseAuth;

  HomeCubit({
    required this._authRepository,
    required this._vehicleRepository,
    firebase.FirebaseAuth? firebaseAuth
  }) : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
       super(HomeInitial());

  Future<void> fetchHomeData(String userId) async {
    emit(HomeLoading());
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      try {
        String? token = await firebaseUser.getIdToken();
        String firebaseId = firebaseUser.uid;
        // Mandamos a pedir PERFIL, SALDO y VEHÍCULOS al mismo tiempo
        final results = await Future.wait([
          _authRepository.getUserProfile(token as String, firebaseId),
          _authRepository.getBalance(token, firebaseId),
          _vehicleRepository.getUserVehicles(userId, token),
          _getActividadSimulada(),
        ]);

        final user = results[0] as User;
        // El nombre lo sacamos del perfil o usamos el ID de backup
        final String name = (user.name != null)
            ? user.name
            : "Usuario";

        emit(HomeLoaded(
          userName: name,
          balance: results[1] as double,
          vehicles: results[2] as List<Vehicle>,
          actividad: results[3] as List<Map<String, dynamic>>,
        ));
      } catch (e) {
        emit(const HomeError("No se pudo cargar la información de Parko"));
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getActividadSimulada() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }
}
