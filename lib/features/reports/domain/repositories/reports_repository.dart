import '../entities/monthly_report.dart';

abstract class ReportsRepository {
  Future<MonthlyReport> getMonthlyReport({
    required int year,
    required int month,
    String? token,
  });
}
