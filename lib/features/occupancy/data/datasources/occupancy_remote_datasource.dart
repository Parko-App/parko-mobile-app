import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_config.dart';
import '../models/occupancy_model.dart';

abstract class OccupancyRemoteDataSource {
  Future<OccupancyModel> getOccupancy({String? token});
}

class OccupancyRemoteDataSourceImpl implements OccupancyRemoteDataSource {
  final http.Client client;

  OccupancyRemoteDataSourceImpl({required this.client});

  @override
  Future<OccupancyModel> getOccupancy({String? token}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/occupancy');

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return OccupancyModel.fromJson(data);
      } else {
        throw Exception('Error al obtener la ocupación (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión al obtener la ocupación');
    }
  }
}
