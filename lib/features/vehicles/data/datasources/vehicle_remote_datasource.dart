import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_config.dart';
import '../models/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  Future<List<VehicleModel>> getUserVehicles(String uuid);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final http.Client client;

  VehicleRemoteDataSourceImpl({required this.client});

  @override
  Future<List<VehicleModel>> getUserVehicles(String uuid) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/vehicle/user/$uuid');

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VehicleModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener los vehículos');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener vehículos');
    }
  }
}
