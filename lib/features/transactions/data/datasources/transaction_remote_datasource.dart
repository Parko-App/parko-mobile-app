import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_config.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getRecentTransactions(String userId, String token);
  Future<List<TransactionModel>> getMonthlyTransactions(String userId, String token, int month, int year);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final http.Client client;

  TransactionRemoteDataSourceImpl({required this.client});

  // MOCK de transacciones pa probar
  final List<TransactionModel> _mockDatabase = [
    TransactionModel(
      id: '1',
      title: 'Estacionamiento UTN',
      date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      time: '10:30 AM',
      amount: 1200,
      type: TransactionType.income,
    ),
    TransactionModel(
      id: '2',
      title: 'Carga de saldo',
      date: '${DateTime.now().day - 1}/${DateTime.now().month}/${DateTime.now().year}',
      time: '04:15 PM',
      amount: 5000,
      type: TransactionType.charge,
    ),
    const TransactionModel(
      id: '3',
      title: 'Estacionamiento UTN',
      date: '28/8/2026',
      time: '08:45 AM',
      amount: 1200,
      type: TransactionType.income,
    ),
    const TransactionModel(
      id: '4',
      title: 'Estacionamiento UTN',
      date: '15/8/2026',
      time: '11:20 AM',
      amount: 1200,
      type: TransactionType.income,
    ),
    const TransactionModel(
      id: '5',
      title: 'Carga de saldo',
      date: '2/8/2026',
      time: '09:00 AM',
      amount: 10000,
      type: TransactionType.charge,
    ),
    const TransactionModel(
      id: '6',
      title: 'Estacionamiento UTN',
      date: '30/7/2026',
      time: '02:30 PM',
      amount: 1200,
      type: TransactionType.income,
    ),
    const TransactionModel(
      id: '7',
      title: 'Carga de saldo',
      date: '10/7/2026',
      time: '01:15 PM',
      amount: 3000,
      type: TransactionType.charge,
    ),
  ];

  @override
  Future<List<TransactionModel>> getRecentTransactions(String userId, String token) async {
    // CUANDO EL BACK ESTÉ LISTO
    /*
    final url = Uri.parse(ApiConfig.getTransactions(userId));
    final response = await client.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    }
    throw Exception('Error al cargar transacciones recientes');
    */

    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDatabase.take(5).toList();
  }

  @override
  Future<List<TransactionModel>> getMonthlyTransactions(String userId, String token, int month, int year) async {
    // CUANDO EL BACK ESTÉ LISTO
    /*
    final url = Uri.parse('${ApiConfig.getTransactions(userId)}?month=$month&year=$year');
    final response = await client.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    }
    throw Exception('Error al cargar historial mensual');
    */

    await Future.delayed(const Duration(milliseconds: 800));
    return _mockDatabase.where((tx) {
      final parts = tx.date.split('/');
      if (parts.length != 3) return false;
      final txMonth = int.tryParse(parts[1]);
      final txYear = int.tryParse(parts[2]);
      return txMonth == month && txYear == year;
    }).toList();
  }
}
