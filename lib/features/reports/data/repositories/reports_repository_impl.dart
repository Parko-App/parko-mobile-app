import '../../domain/entities/monthly_report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_local_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsLocalDataSource localDataSource;

  ReportsRepositoryImpl({required this.localDataSource});

  @override
  Future<MonthlyReport> getMonthlyReport({
    required int year,
    required int month,
    String? token,
  }) async {
    return await localDataSource.getMonthlyReport(year: year, month: month);
  }
}
