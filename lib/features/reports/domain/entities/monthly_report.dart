import 'package:equatable/equatable.dart';

class MonthlyReport extends Equatable {
  final double totalSpent;
  final int daysInCampus;
  final int avgStayHours;
  final int avgStayMinutes;
  final int weekAverage;
  final String summaryNote;
  final List<DailyOccupancy> dailyOccupancy;

  const MonthlyReport({
    required this.totalSpent,
    required this.daysInCampus,
    required this.avgStayHours,
    required this.avgStayMinutes,
    required this.weekAverage,
    required this.summaryNote,
    required this.dailyOccupancy,
  });

  @override
  List<Object?> get props => [
        totalSpent,
        daysInCampus,
        avgStayHours,
        avgStayMinutes,
        weekAverage,
        summaryNote,
        dailyOccupancy,
      ];
}

class DailyOccupancy extends Equatable {
  final String day;
  final int percentage;

  const DailyOccupancy({
    required this.day,
    required this.percentage,
  });

  @override
  List<Object?> get props => [day, percentage];
}
