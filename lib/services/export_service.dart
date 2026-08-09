import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/contributor.dart';
import '../models/payment.dart';

class ExportService {
  // Generate CSV text for contributors and their payment status
  static String generateCsv(List<Contributor> contributors, List<Payment> payments) {
    final currencyFormatter = NumberFormat.currency(symbol: 'INR ', decimalDigits: 2);
    final List<List<dynamic>> rows = [];

    // Header row
    rows.add([
      'Member ID',
      'Name',
      'Phone',
      'Address',
      'Amount Due (INR)',
      'Amount Paid (INR)',
      'Pending Amount (INR)',
      'Payment Status',
      'Last Payment Date',
      'Notes'
    ]);

    // Data rows
    for (final c in contributors) {
      final amountPaid = c.getAmountPaid(payments);
      final pending = c.getPendingAmount(payments);
      final status = c.getStatus(payments).label;
      final lastDate = c.getLastPaymentDate(payments);
      final formattedDate = lastDate != null
          ? DateFormat('yyyy-MM-dd').format(lastDate)
          : 'N/A';

      rows.add([
        c.id,
        c.name,
        c.phone,
        c.address,
        currencyFormatter.format(c.amountDue),
        currencyFormatter.format(amountPaid),
        currencyFormatter.format(pending),
        status,
        formattedDate,
        c.notes ?? '',
      ]);
    }

    return rows.map((row) {
      return row.map((cell) => '"${cell.toString().replaceAll('"', '""')}"').join(',');
    }).join('\n');
  }

  // Generate & print/save PDF document
  static Future<void> generateAndPrintPdf({
    required List<Contributor> contributors,
    required List<Payment> payments,
    required double totalExpected,
    required double totalCollected,
    required double pendingAmount,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Title & Banner Header
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#0F382C'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ONAM FUND CONTRIBUTION REPORT 2026',
                        style: pw.TextStyle(
                          color: PdfColor.fromHex('#D4AF37'),
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Onam Celebration Committee Member Directory & Payment Summary',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Summary Metrics Box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#D4AF37'), width: 1),
                borderRadius: pw.BorderRadius.circular(6),
                color: PdfColor.fromHex('#FFFDF5'),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _pdfStatColumn('Total Members', '${contributors.length}'),
                  _pdfStatColumn('Total Expected', currencyFormat.format(totalExpected)),
                  _pdfStatColumn('Total Collected', currencyFormat.format(totalCollected)),
                  _pdfStatColumn('Pending Balance', currencyFormat.format(pendingAmount)),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Contributors Table
            pw.Text(
              'Member Contribution Details',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0F382C'),
              ),
            ),
            pw.SizedBox(height: 8),

            pw.TableHelper.fromTextArray(
              headers: ['Member ID', 'Name', 'Phone', 'Due', 'Paid', 'Pending', 'Status'],
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#1E513B'),
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              cellAlignment: pw.Alignment.centerLeft,
              data: contributors.map((c) {
                final paid = c.getAmountPaid(payments);
                final pending = c.getPendingAmount(payments);
                final status = c.getStatus(payments).label;

                return [
                  c.id,
                  c.name,
                  c.phone,
                  currencyFormat.format(c.amountDue),
                  currencyFormat.format(paid),
                  currencyFormat.format(pending),
                  status,
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 24),

            // Footer note
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Generated automatically by Onam Fund Tracker',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Onam_Fund_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _pdfStatColumn(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#0F382C'),
          ),
        ),
      ],
    );
  }
}
