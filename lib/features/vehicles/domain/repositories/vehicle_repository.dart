import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getUserVehicles(String uuid, String token);
  Future<Vehicle> addVehicle(String uuid, String token, String plate, String brand, String model);
}
