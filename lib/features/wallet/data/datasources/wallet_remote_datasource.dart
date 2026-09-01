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

  static const _pollInterval = Duration(milliseconds: 800);
  static const _pollTimeout = Duration(seconds: 15);

  WalletRemoteDataSourceImpl({required this.client});

  @override
  Future<String> createTopUpPreference({
    required String uuid,
    required String token,
    required double amount,
  }) async {
    final operationId = await _createTopUp(uuid: uuid, token: token, amount: amount);
    final preferenceId = await _pollPreference(operationId: operationId, token: token);
    return 'https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=$preferenceId';
  }

  Future<String> _createTopUp({
    required String uuid,
    required String token,
    required double amount,
  }) async {
    final url = Uri.parse('${ApiConfig.balanceBaseUrl}/api/v1/balance/topup');

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

      if (response.statusCode == 202) {
        return jsonDecode(response.body) as String; // operationId
      }
      throw Exception('Error al generar la preferencia de pago');
    } catch (e) {
      throw Exception('Error de conexión con el servidor de pagos');
    }
  }

  Future<String> _pollPreference({
    required String operationId,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.balanceBaseUrl}/api/v1/balance/topup/$operationId/preference');
    final deadline = DateTime.now().add(_pollTimeout);

    while (DateTime.now().isBefore(deadline)) {
      final response = await client.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['preferenceId'] as String;
      }
      if (response.statusCode != 404) {
        throw Exception('Error al consultar la preferencia de pago');
      }

      await Future.delayed(_pollInterval);
    }

    throw Exception('La preferencia de pago demoró demasiado en generarse');
  }
}
