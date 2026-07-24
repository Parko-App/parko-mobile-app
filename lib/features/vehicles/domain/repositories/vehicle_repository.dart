import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getUserVehicles(String uuid);
}
