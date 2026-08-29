import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/vehicle.dart';

class VehicleDetailDialog extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailDialog({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_car_rounded, 
                color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              "Detalles del vehículo",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow("Patente", vehicle.plate.toUpperCase()),
            const SizedBox(height: 12),
            _buildDetailRow("Marca", vehicle.brand),
            const SizedBox(height: 12),
            _buildDetailRow("Modelo", vehicle.model),
            const SizedBox(height: 12),
            _buildDetailRow("Estado", vehicle.active ? "Activo" : "Inactivo", 
              valueColor: vehicle.active ? Colors.green : Colors.red),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

void showVehicleDetail(BuildContext context, Vehicle vehicle) {
  showDialog(
    context: context,
    builder: (context) => VehicleDetailDialog(vehicle: vehicle),
  );
}
