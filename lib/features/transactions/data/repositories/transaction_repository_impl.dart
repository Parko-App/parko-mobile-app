import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Transaction>> getRecentTransactions(String userId, String token) async {
    return await remoteDataSource.getRecentTransactions(userId, token);
  }

  @override
  Future<List<Transaction>> getMonthlyTransactions(String userId, String token, int month, int year) async {
    return await remoteDataSource.getMonthlyTransactions(userId, token, month, year);
  }
}
