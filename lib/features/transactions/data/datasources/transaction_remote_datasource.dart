import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_config.dart';
import '../models/transaction_model.dart';
import '../models/transaction_page_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getRecentTransactions(String userId, String token);
  Future<TransactionPageModel> getMonthlyTransactions(
    String userId,
    String token,
    int month,
    int year, {
    int page = 0,
    int size = 20,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final http.Client client;

  TransactionRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TransactionModel>> getRecentTransactions(String userId, String token) async {
    final url = Uri.parse(ApiConfig.getTransactions());
    final response = await client.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['content'] as List<dynamic>? ?? [];
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    }
    throw Exception('Error al cargar transacciones recientes');
  }

  @override
  Future<TransactionPageModel> getMonthlyTransactions(
    String userId,
    String token,
    int month,
    int year, {
    int page = 0,
    int size = 20,
  }) async {
    final url = Uri.parse('${ApiConfig.getTransactions()}?month=$month&year=$year&page=$page&size=$size');
    final response = await client.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return TransactionPageModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al cargar historial mensual');
  }
}
