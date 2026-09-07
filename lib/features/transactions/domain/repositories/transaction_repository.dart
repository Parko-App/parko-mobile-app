import '../entities/transaction.dart';
import '../entities/transaction_page.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getRecentTransactions(String userId, String token);
  Future<TransactionPage> getMonthlyTransactions(
    String userId,
    String token,
    int month,
    int year, {
    int page = 0,
    int size = 20,
  });
}
