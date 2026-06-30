import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction.dart';

class PdfHelper {
  static Future<void> generateAndPrintReport(
      List<Transaction> transactions, int month, int year) async {
    final pdf = pw.Document();
    final formatCurrency =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final formatDate = DateFormat('dd MMM yyyy');

    double totalIncome = 0;
    double totalExpense = 0;

    for (var txn in transactions) {
      if (txn.category.value?.type == 'income') {
        totalIncome += txn.amount;
      } else {
        totalExpense += txn.amount;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Keuangan FinTrack Pro',
                  style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900)),
              pw.SizedBox(height: 8),
              pw.Text('Periode: Bulan $month Tahun $year',
                  style: const pw.TextStyle(
                      fontSize: 14, color: PdfColors.grey700)),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'Total Pemasukan: ${formatCurrency.format(totalIncome)}',
                      style: pw.TextStyle(
                          color: PdfColors.green700,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14)),
                  pw.Text(
                      'Total Pengeluaran: ${formatCurrency.format(totalExpense)}',
                      style: pw.TextStyle(
                          color: PdfColors.red700,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.TableHelper.fromTextArray(
                context: context,
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.blueGrey50),
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900),
                cellStyle: const pw.TextStyle(color: PdfColors.blueGrey800),
                headerHeight: 40,
                cellHeight: 35,
                headers: ['Tanggal', 'Kategori', 'Tipe', 'Nominal'],
                data: transactions.map((txn) {
                  final isIncome = txn.category.value?.type == 'income';
                  final operator = isIncome ? '+' : '-';
                  return [
                    formatDate.format(txn.date),
                    txn.category.value?.name ?? 'Lainnya',
                    isIncome ? 'Pemasukan' : 'Pengeluaran',
                    '$operator ${formatCurrency.format(txn.amount)}',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_FinTrack_${month}_$year.pdf',
    );
  }
}
