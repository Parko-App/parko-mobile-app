import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_config.dart';
import '../models/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  Future<List<VehicleModel>> getUserVehicles(String uuid, String token);
  Future<VehicleModel> addVehicle(String uuid, String token, String plate, String brand, String model);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final http.Client client;

  VehicleRemoteDataSourceImpl({required this.client});

  @override
  Future<List<VehicleModel>> getUserVehicles(String uuid, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/vehicle/user/$uuid');

    try {
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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

  @override
  Future<VehicleModel> addVehicle(String uuid, String token, String plate, String brand, String model) async {
    // Cambiamos el endpoint para usar el UUID del backend
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/vehicle/user/$uuid');

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'plate': plate,
          'brand': brand,
          'model': model,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return VehicleModel.fromJson(jsonDecode(response.body));
      } else {
        // Intentamos sacar el mensaje del backend
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión al registrar vehículo');
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        return body['message'] as String;
      }
    } catch (_) {}
    return 'Error al registrar el vehículo (${response.statusCode})';
  }
}
