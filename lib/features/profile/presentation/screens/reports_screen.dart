import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _reportsJsonMap;
  bool _isLoading = true;

  static const List<String> _months = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
  ];

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/reports_mock.json');
      setState(() {
        _reportsJsonMap = jsonDecode(jsonString);
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  MonthlyReportData _getReportForSelectedDate() {
    final String key = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}";
    
    if (_reportsJsonMap != null && _reportsJsonMap!.containsKey(key)) {
      return MonthlyReportData.fromJson(_reportsJsonMap![key]);
    }

    // Generador de fallback determinado si la fecha seleccionada no está en el JSON
    return MonthlyReportData.defaultForMonth(_selectedDate.month, _selectedDate.year);
  }

  @override
  Widget build(BuildContext context) {
    final String currentMonthName = _months[_selectedDate.month - 1];
    final String yearString = _selectedDate.year.toString();
    final MonthlyReportData currentReport = _getReportForSelectedDate();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Reportes y Estadísticas",
          style: GoogleFonts.nunito(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Control de Navegación por Mes y Año
                  _buildMonthSelector(currentMonthName, yearString),

                  const SizedBox(height: 24),

                  // Tarjetas Rápidas de Resumen (KPIs del mes seleccionado)
                  _buildSummaryKPIs(currentReport),

                  const SizedBox(height: 32),

                  // Gráfico de Ocupación Diaria de la Semana del mes seleccionado
                  _buildDailyOccupancySection(currentReport),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthSelector(String monthName, String year) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary, size: 28),
            onPressed: _previousMonth,
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "$monthName $year",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 28),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryKPIs(MonthlyReportData report) {
    final String formattedSpent = "\$ ${report.totalSpent.toStringAsFixed(0)}";
    final String formattedDays = "${report.daysInCampus} días";
    final String formattedStay = "${report.avgStayHours} hs ${report.avgStayMinutes} min";

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: "Gasto total",
                value: formattedSpent,
                icon: Icons.payments_outlined,
                accentColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: "Días en campus",
                value: formattedDays,
                icon: Icons.date_range_rounded,
                accentColor: const Color(0xFF00C853),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildKpiCard(
          title: "Permanencia promedio diaria",
          value: formattedStay,
          subtitle: "Basado en tus estadías de este mes",
          icon: Icons.access_time_rounded,
          accentColor: const Color(0xFFFF9100),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    String? subtitle,
    bool isFullWidth = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              if (isFullWidth) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ]
            ],
          ),
          const SizedBox(height: 12),
          if (!isFullWidth) ...[
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyOccupancySection(MonthlyReportData report) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Ocupación diaria (Última semana)",
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Promedio ${report.weekAverage}%",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gráfico de Barras de Ocupación con animación fluida
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: report.dailyOccupancy.map((data) => _buildBarItem(data)).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Leyenda explicativa basada en los datos del mes seleccionado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.alternateBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    report.summaryNote,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarItem(DailyOccupancyItem data) {
    final bool isHigh = data.percentage >= 85;
    final Color barColor = isHigh ? AppColors.error : AppColors.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "${data.percentage}%",
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: barColor,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: 28,
          height: (data.percentage / 100) * 110,
          decoration: BoxDecoration(
            color: barColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                barColor,
                barColor.withValues(alpha: 0.6),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.day,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class MonthlyReportData {
  final double totalSpent;
  final int daysInCampus;
  final int avgStayHours;
  final int avgStayMinutes;
  final int weekAverage;
  final String summaryNote;
  final List<DailyOccupancyItem> dailyOccupancy;

  MonthlyReportData({
    required this.totalSpent,
    required this.daysInCampus,
    required this.avgStayHours,
    required this.avgStayMinutes,
    required this.weekAverage,
    required this.summaryNote,
    required this.dailyOccupancy,
  });

  factory MonthlyReportData.fromJson(Map<String, dynamic> json) {
    return MonthlyReportData(
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      daysInCampus: json['daysInCampus'] ?? 0,
      avgStayHours: json['avgStayHours'] ?? 0,
      avgStayMinutes: json['avgStayMinutes'] ?? 0,
      weekAverage: json['weekAverage'] ?? 0,
      summaryNote: json['summaryNote'] ?? '',
      dailyOccupancy: (json['dailyOccupancy'] as List<dynamic>?)
              ?.map((e) => DailyOccupancyItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory MonthlyReportData.defaultForMonth(int month, int year) {
    return MonthlyReportData(
      totalSpent: 11000 + (month * 450),
      daysInCampus: 10 + (month % 6),
      avgStayHours: 4,
      avgStayMinutes: 15,
      weekAverage: 70 + (month % 15),
      summaryNote: "Estadísticas estimadas para el periodo $month/$year.",
      dailyOccupancy: [
        DailyOccupancyItem(day: "Lun", percentage: 70 + (month % 10)),
        DailyOccupancyItem(day: "Mar", percentage: 80 + (month % 12)),
        DailyOccupancyItem(day: "Mié", percentage: 75 + (month % 8)),
        DailyOccupancyItem(day: "Jue", percentage: 65 + (month % 14)),
        DailyOccupancyItem(day: "Vie", percentage: 45 + (month % 10)),
      ],
    );
  }
}

class DailyOccupancyItem {
  final String day;
  final int percentage;

  DailyOccupancyItem({required this.day, required this.percentage});

  factory DailyOccupancyItem.fromJson(Map<String, dynamic> json) {
    return DailyOccupancyItem(
      day: json['day'] ?? '',
      percentage: json['percentage'] ?? 0,
    );
  }
}
