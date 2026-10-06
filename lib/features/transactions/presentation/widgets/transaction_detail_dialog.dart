import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/transaction.dart';
import '../utils/ticket_pdf_generator.dart';

class TransactionDetailDialog extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.type == TransactionType.income;
    final String typeText = isExpense ? "pago de estacionamiento" : "carga de saldo";
    final Color statusColor = isExpense ? AppColors.error : AppColors.success;

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
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense ? Icons.directions_car_filled_outlined : Icons.add_card_outlined,
                color: statusColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Detalle del movimiento",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Realizaste un $typeText el día ${transaction.date} a las ${transaction.time} por un monto de \$${transaction.amount}.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow("Concepto", transaction.title),
            const SizedBox(height: 12),
            _buildDetailRow("Fecha", transaction.date),
            const SizedBox(height: 12),
            _buildDetailRow("Hora", transaction.time),
            const SizedBox(height: 12),
            _buildDetailRow(
              "Monto", 
              "${isExpense ? '-' : '+'} \$${transaction.amount}",
              valueColor: statusColor,
            ),
            const SizedBox(height: 28),

            // Botón para Descargar Ticket PDF (Disponible para todos los movimientos)
            OutlinedButton.icon(
              onPressed: () {
                TicketPdfGenerator.generateAndShareTicket(transaction);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
              label: Text(
                "Descargar Ticket (PDF)",
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Entendido"),
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

void showTransactionDetail(BuildContext context, Transaction transaction) {
  showDialog(
    context: context,
    builder: (context) => TransactionDetailDialog(transaction: transaction),
  );
}
