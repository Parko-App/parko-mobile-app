import 'package:equatable/equatable.dart';
import '../../domain/entities/monthly_report.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final MonthlyReport report;
  final DateTime selectedDate;

  const ReportsLoaded({
    required this.report,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [report, selectedDate];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
