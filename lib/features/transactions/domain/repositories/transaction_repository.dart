import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getRecentTransactions(String userId, String token);
  Future<List<Transaction>> getMonthlyTransactions(String userId, String token, int month, int year);
}
