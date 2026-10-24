import '../../domain/entities/monthly_report.dart';

class MonthlyReportModel extends MonthlyReport {
  const MonthlyReportModel({
    required super.totalSpent,
    required super.daysInCampus,
    required super.avgStayHours,
    required super.avgStayMinutes,
    required super.weekAverage,
    required super.summaryNote,
    required super.dailyOccupancy,
  });

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) {
    return MonthlyReportModel(
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      daysInCampus: json['daysInCampus'] ?? 0,
      avgStayHours: json['avgStayHours'] ?? 0,
      avgStayMinutes: json['avgStayMinutes'] ?? 0,
      weekAverage: json['weekAverage'] ?? 0,
      summaryNote: json['summaryNote'] ?? '',
      dailyOccupancy: (json['dailyOccupancy'] as List<dynamic>?)
              ?.map((e) => DailyOccupancyModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSpent': totalSpent,
      'daysInCampus': daysInCampus,
      'avgStayHours': avgStayHours,
      'avgStayMinutes': avgStayMinutes,
      'weekAverage': weekAverage,
      'summaryNote': summaryNote,
      'dailyOccupancy':
          dailyOccupancy.map((e) => (e as DailyOccupancyModel).toJson()).toList(),
    };
  }

  factory MonthlyReportModel.defaultForMonth(int month, int year) {
    return MonthlyReportModel(
      totalSpent: 11000 + (month * 450),
      daysInCampus: 10 + (month % 6),
      avgStayHours: 4,
      avgStayMinutes: 15,
      weekAverage: 70 + (month % 15),
      summaryNote: "Estadísticas registradas para el periodo $month/$year.",
      dailyOccupancy: [
        DailyOccupancyModel(day: "Lun", percentage: 70 + (month % 10)),
        DailyOccupancyModel(day: "Mar", percentage: 80 + (month % 12)),
        DailyOccupancyModel(day: "Mié", percentage: 75 + (month % 8)),
        DailyOccupancyModel(day: "Jue", percentage: 65 + (month % 14)),
        DailyOccupancyModel(day: "Vie", percentage: 45 + (month % 10)),
      ],
    );
  }
}

class DailyOccupancyModel extends DailyOccupancy {
  const DailyOccupancyModel({
    required super.day,
    required super.percentage,
  });

  factory DailyOccupancyModel.fromJson(Map<String, dynamic> json) {
    return DailyOccupancyModel(
      day: json['day'] ?? '',
      percentage: json['percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'percentage': percentage,
    };
  }
}
