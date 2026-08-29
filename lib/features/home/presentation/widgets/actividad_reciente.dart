import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ActividadReciente extends StatelessWidget {
  final List<Map<String, dynamic>> actividad;

  const ActividadReciente({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    if (actividad.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Todavía no tenés movimientos",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "¡Tus estacionamientos aparecerán acá!",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actividad.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = actividad[index];
        final bool isIngreso = item['type'] == 'ingreso';
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isIngreso ? Colors.red : Colors.green).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIngreso ? Icons.arrow_back_outlined : Icons.money,
                  color: isIngreso ? Colors.red : Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "${item['date']} • ${item['time']}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${isIngreso ? '-' : '+'} \$ ${item['amount']}",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isIngreso ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
