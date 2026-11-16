import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Vehicle>> getUserVehicles(String uuid, String token) async {
    return await remoteDataSource.getUserVehicles(uuid, token);
  }

  @override
  Future<Vehicle> addVehicle(String uuid, String token, String plate, String brand, String model) async {
    return await remoteDataSource.addVehicle(uuid, token, plate, brand, model);
  }

  @override
  Future<void> deleteVehicle(String vehicleId, String token) async {
    return await remoteDataSource.deleteVehicle(vehicleId, token);
  }
}
