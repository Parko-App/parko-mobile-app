import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_infoautos.dart';
import '../models/car_brand_model.dart';
import '../models/car_model_model.dart';

abstract class CarInfoRemoteDataSource {
  Future<List<CarBrandModel>> getBrands();
  Future<List<CarModelModel>> getModels(int brandId);
}

class CarInfoRemoteDataSourceImpl implements CarInfoRemoteDataSource {
  final http.Client client;
  final String? apiKey = null;

  CarInfoRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CarBrandModel>> getBrands() async {
    final url = Uri.parse(ApiInfoautos.brandsEndpoint);
    
    try {
      final response = await client.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'] ?? [];
        return data.map((json) => CarBrandModel.fromJson(json)).toList();
      }
      throw Exception('Fallo al cargar marcas');
    } catch (e) {

      return const [
        CarBrandModel(id: 1, name: "TOYOTA"),
        CarBrandModel(id: 2, name: "FORD"),
        CarBrandModel(id: 3, name: "FIAT"),
        CarBrandModel(id: 4, name: "VOLKSWAGEN"),
        CarBrandModel(id: 5, name: "RENAULT"),
      ];
    }
  }

  @override
  Future<List<CarModelModel>> getModels(int brandId) async {
    final url = Uri.parse(ApiInfoautos.getBrandModels(brandId));
    
    try {
      final response = await client.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'] ?? [];
        return data.map((json) => CarModelModel.fromJson(json)).toList();
      }
      throw Exception('Fallo al cargar modelos');
    } catch (e) {
      return const [CarModelModel(id: 1, name: "Modelo no disponible (Escribir manual)")];
    }
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (apiKey != null) 'Authorization': 'Bearer $apiKey',
  };
}
