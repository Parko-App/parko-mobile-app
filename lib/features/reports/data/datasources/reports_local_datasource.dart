import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/monthly_report_model.dart';

abstract class ReportsLocalDataSource {
  Future<MonthlyReportModel> getMonthlyReport({
    required int year,
    required int month,
  });
}

class ReportsLocalDataSourceImpl implements ReportsLocalDataSource {
  Map<String, dynamic>? _cachedJsonMap;

  @override
  Future<MonthlyReportModel> getMonthlyReport({
    required int year,
    required int month,
  }) async {
    if (_cachedJsonMap == null) {
      try {
        final String jsonString =
            await rootBundle.loadString('assets/data/reports_mock.json');
        _cachedJsonMap = jsonDecode(jsonString);
      } catch (_) {
        _cachedJsonMap = {};
      }
    }

    final String key = "$year-${month.toString().padLeft(2, '0')}";

    if (_cachedJsonMap != null && _cachedJsonMap!.containsKey(key)) {
      return MonthlyReportModel.fromJson(_cachedJsonMap![key]);
    }

    return MonthlyReportModel.defaultForMonth(month, year);
  }
}
