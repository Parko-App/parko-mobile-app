import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/reports_repository.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository reportsRepository;
  DateTime _selectedDate = DateTime.now();

  ReportsCubit({required this.reportsRepository}) : super(ReportsInitial());

  DateTime get selectedDate => _selectedDate;

  Future<void> fetchMonthlyReport({DateTime? date, String? token}) async {
    if (date != null) {
      _selectedDate = DateTime(date.year, date.month);
    }

    emit(ReportsLoading());

    try {
      final report = await reportsRepository.getMonthlyReport(
        year: _selectedDate.year,
        month: _selectedDate.month,
        token: token,
      );
      emit(ReportsLoaded(report: report, selectedDate: _selectedDate));
    } catch (e) {
      emit(const ReportsError("No se pudo obtener el reporte"));
    }
  }

  void previousMonth({String? token}) {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    fetchMonthlyReport(token: token);
  }

  void nextMonth({String? token}) {
    final now = DateTime.now();
    final candidateNext = DateTime(_selectedDate.year, _selectedDate.month + 1);

    // Validación estricta: No se permite navegar a meses futuros
    if (candidateNext.year > now.year ||
        (candidateNext.year == now.year && candidateNext.month > now.month)) {
      return;
    }

    _selectedDate = candidateNext;
    fetchMonthlyReport(token: token);
  }
}
