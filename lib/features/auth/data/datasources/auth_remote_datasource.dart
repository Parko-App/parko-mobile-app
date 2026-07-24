import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_config.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String institutionalDomain,
    required bool termsAccepted,
  });

  Future<UserModel> getUserProfile(String email);

  Future<double> getBalance(String uuid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<double> getBalance(String uuid) async {
    final url = Uri.parse(ApiConfig.getBalance(uuid));

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['balance'] as num).toDouble();
      } else {
        throw Exception('No se pudo obtener el saldo del backend');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener el saldo');
    }
  }

  @override
  Future<UserModel> getUserProfile(String email) async {
    final url = Uri.parse(ApiConfig.getUserProfile(email));

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Usuario no encontrado en el backend');
      }
    } catch (_) {
      throw Exception('Error al conectar con el servidor para obtener el perfil');
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String institutionalDomain,
    required bool termsAccepted,
  }) async {
    final url = Uri.parse(ApiConfig.userEndpoint);

    http.Response response;
    try {
      response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': name,
          'email': email,
          'studentId': studentId,
          'password': password,
          'institutionalDomain': institutionalDomain,
          'termsAndConditionsAccepted': termsAccepted,
        }),
      );
    } catch (_) {
      throw Exception('No se pudo conectar con el servidor');
    }

    if (response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_extractErrorMessage(response));
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        return body['message'] as String;
      }
    } catch (_) {}
    return 'Error al registrar usuario (${response.statusCode})';
  }
}
