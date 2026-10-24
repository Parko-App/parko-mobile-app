import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/transaction.dart';

class TicketPdfGenerator {
  static Future<void> generateAndShareTicket(Transaction transaction) async {
    final pdf = pw.Document();

    final fontBold = await PdfGoogleFonts.nunitoBold();
    final fontRegular = await PdfGoogleFonts.interRegular();

    final bool isExpense = transaction.type == TransactionType.income;
    final String typeLabel = isExpense ? "Pago de Estacionamiento" : "Carga de Saldo";
    final PdfColor primaryColor = PdfColor.fromInt(0xFF0B3D91);
    final PdfColor statusColor = isExpense ? PdfColor.fromInt(0xFFD64545) : PdfColor.fromInt(0xFF2F9E58);

    String shortId = transaction.id.trim();
    if (shortId.length > 6) {
      shortId = shortId.substring(shortId.length - 6).toUpperCase();
    } else {
      shortId = shortId.toUpperCase();
    }
    final String ticketNumber = "#TX-$shortId";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromInt(0xFFE0E0E0), width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                // Cabecera
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "PARKO",
                      style: pw.TextStyle(
                        fontSize: 22,
                        font: fontBold,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: statusColor,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Text(
                        "COMPROBANTE",
                        style: pw.TextStyle(
                          fontSize: 9,
                          font: fontBold,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Divider(color: PdfColor.fromInt(0xFFEEEEEE)),
                pw.SizedBox(height: 12),

                // Título del tipo de transacción
                pw.Text(
                  typeLabel,
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: fontBold,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF111111),
                  ),
                ),
                pw.Text(
                  transaction.title,
                  style: pw.TextStyle(
                    fontSize: 11,
                    font: fontRegular,
                    color: PdfColor.fromInt(0xFF666666),
                  ),
                ),
                pw.SizedBox(height: 16),

                // Detalles
                _buildPdfRow("N° Transacción", ticketNumber, fontRegular, fontBold),
                pw.SizedBox(height: 6),
                _buildPdfRow("Fecha", transaction.date, fontRegular, fontBold),
                pw.SizedBox(height: 6),
                _buildPdfRow("Hora", transaction.time, fontRegular, fontBold),
                pw.SizedBox(height: 12),
                pw.Divider(color: PdfColor.fromInt(0xFFEEEEEE)),
                pw.SizedBox(height: 12),

                // Monto
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Monto Total",
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: fontBold,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF111111),
                      ),
                    ),
                    pw.Text(
                      "${isExpense ? '-' : '+'} \$ ${transaction.amount}",
                      style: pw.TextStyle(
                        fontSize: 16,
                        font: fontBold,
                        fontWeight: pw.FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),
                // Código QR de Verificación
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: "https://parko.site/verify/tx/$shortId",
                    width: 55,
                    height: 55,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    "Comprobante oficial emitido por Parko",
                    style: pw.TextStyle(fontSize: 8, font: fontRegular, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "ticket_parko_$shortId.pdf",
    );
  }

  static pw.Widget _buildPdfRow(
    String label,
    String value,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, font: fontRegular, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 10, font: fontBold, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
