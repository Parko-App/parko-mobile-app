import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../wallet/presentation/screens/top_up_screen.dart';
import '../../domain/entities/transaction.dart';
import '../utils/ticket_pdf_generator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionDetailDialog extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailDialog({super.key, required this.transaction});

  String _getStatusText(bool hasEnoughBalance) {
    if (transaction.isPending) {
      if (transaction.type == TransactionType.income) {
        return hasEnoughBalance ? "Pendiente de cobro" : "Pendiente de pago";
      }
      return "Acreditación pendiente";
    }
    if (transaction.isFailed) return "Carga fallida";
    return "Completado";
  }

  Color _getStatusColor(bool hasEnoughBalance) {
    if (transaction.isPending) {
      return hasEnoughBalance ? Colors.amber.shade800 : Colors.orange.shade800;
    }
    if (transaction.isFailed) return AppColors.error;
    return transaction.type == TransactionType.income ? AppColors.error : AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final double userBalance = (authState is Authenticated) ? (authState.user.balance ?? 0.0) : 0.0;
    final bool isExpense = transaction.type == TransactionType.income;
    final bool hasEnoughBalance = userBalance >= transaction.amount;

    final String typeText = isExpense ? "pago de estacionamiento" : "carga de saldo";
    final Color statusColor = _getStatusColor(hasEnoughBalance);
    String provider = transaction.paymentProvider ?? (isExpense ? "Saldo de Parko" : "Mercado Pago");
    if (provider.toLowerCase() == 'internal_balance' || provider.toLowerCase() == 'internalbalance') {
      provider = 'Saldo de Parko';
    }

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
                transaction.isPending
                    ? Icons.pending_outlined
                    : (transaction.isFailed
                        ? Icons.error_outline_rounded
                        : (isExpense ? Icons.directions_car_filled_outlined : Icons.add_card_outlined)),
                color: statusColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Detalle del movimiento",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Badge de Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
              ),
              child: Text(
                _getStatusText(hasEnoughBalance),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              "Movimiento correspondiente a $typeText el día ${transaction.date} a las ${transaction.time}.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _buildDetailRow("Concepto", transaction.title),
            const SizedBox(height: 10),
            _buildDetailRow("Método de pago", provider),
            const SizedBox(height: 10),
            _buildDetailRow("Fecha", transaction.date),
            const SizedBox(height: 10),
            _buildDetailRow("Hora", transaction.time),
            const SizedBox(height: 10),
            _buildDetailRow(
              "Monto", 
              "${isExpense ? '-' : '+'} \$${transaction.amount}",
              valueColor: statusColor,
            ),
            const SizedBox(height: 20),

            if (transaction.isPending && isExpense) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: hasEnoughBalance ? const Color(0xFFE8F5E9) : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasEnoughBalance ? const Color(0xFFA5D6A7) : Colors.orange.shade300,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasEnoughBalance ? Icons.info_outline : Icons.warning_amber_rounded,
                          size: 18,
                          color: hasEnoughBalance ? const Color(0xFF2E7D32) : Colors.orange.shade900,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hasEnoughBalance
                                ? "A la salida se cobrará el estacionamiento."
                                : "Cargá saldo para poder pagar.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: hasEnoughBalance ? const Color(0xFF2E7D32) : Colors.orange.shade900,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!hasEnoughBalance) ...[
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TopUpScreen(initialBalance: userBalance),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Cargar saldo ahora"),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

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
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
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
