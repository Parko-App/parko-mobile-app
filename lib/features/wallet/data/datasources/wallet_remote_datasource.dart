import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_config.dart';

abstract class WalletRemoteDataSource {
  Future<String> createTopUpPreference({
    required String uuid,
    required String token,
    required double amount,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final http.Client client;

  WalletRemoteDataSourceImpl({required this.client});

  @override
  Future<String> createTopUpPreference({
    required String uuid,
    required String token,
    required double amount,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/wallet/topup');

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': uuid,
          'amount': amount,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['initPoint'] as String; // URL que devuelve el back
      } else {
        throw Exception('Error al generar la preferencia de pago');
      }

    } catch (e) {
      throw Exception('Error de conexión con el servidor de pagos');
    }
  }
}
