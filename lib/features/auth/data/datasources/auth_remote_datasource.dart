import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? legajo,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? legajo,
  }) async {
    // Acá va al back? ponele vo
    final url = Uri.parse('');

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'legajo': legajo,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Si el backend responde bien, parseamos el JSON al modelo
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        // Si falla, tiramos una excepción, basico basico
        throw Exception('Error al registrar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o de servidor: $e');
    }
  }
}
