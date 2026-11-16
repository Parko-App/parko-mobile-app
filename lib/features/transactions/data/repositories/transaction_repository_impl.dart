import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_page.dart';
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
  Future<TransactionPage> getMonthlyTransactions(
    String userId,
    String token,
    int month,
    int year, {
    int page = 0,
    int size = 20,
  }) async {
    return await remoteDataSource.getMonthlyTransactions(userId, token, month, year, page: page, size: size);
  }
}
