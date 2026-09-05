import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/domain/repositories/vehicle_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AuthRepository _authRepository;
  final VehicleRepository _vehicleRepository;
  final AuthCubit _authCubit;
  final firebase.FirebaseAuth _firebaseAuth;

  HomeCubit({
    required AuthRepository authRepository,
    required VehicleRepository vehicleRepository,
    required AuthCubit authCubit,
    firebase.FirebaseAuth? firebaseAuth
  }) : _authRepository = authRepository,
       _vehicleRepository = vehicleRepository,
       _authCubit = authCubit,
       _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
       super(HomeInitial());

  Future<void> fetchHomeData(String userId) async {
    emit(HomeLoading());
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      try {
        String? token = await firebaseUser.getIdToken();
        String firebaseId = firebaseUser.uid;

        final results = await Future.wait([
          _authRepository.getUserProfile(token as String, firebaseId),
          _authRepository.getBalance(token, firebaseId),
          _vehicleRepository.getUserVehicles(userId, token),
          _getActividadReciente(),
        ]);

        final user = results[0] as User;
        final double balance = results[1] as double;
        final String name = (user.name != null) ? user.name : "Usuario";

        _authCubit.updateBalance(balance);

        emit(HomeLoaded(
          userName: name,
          balance: balance,
          vehicles: results[2] as List<Vehicle>,
          actividad: results[3] as List<Map<String, dynamic>>,
        ));
      } catch (e) {
        emit(const HomeError("No se pudo cargar la información de Parko"));
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getActividadReciente() async {
    // Mock de datos de actividad
    return [
      {
        'title': 'Estacionamiento UTN',
        'date': 'Hoy',
        'time': '10:30 AM',
        'amount': '1.200',
        'type': 'ingreso',
      },
      {
        'title': 'Carga de saldo',
        'date': 'Ayer',
        'time': '04:15 PM',
        'amount': '5.000',
        'type': 'carga',
      },
      {
        'title': 'Estacionamiento UTN',
        'date': '15 Ago',
        'time': '08:45 AM',
        'amount': '1.200',
        'type': 'ingreso',
      },
    ];
  }
}
