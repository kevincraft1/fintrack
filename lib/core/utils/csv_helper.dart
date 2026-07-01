import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/transaction.dart';

class CsvHelper {
  static Future<void> generateAndShareCsv(
      List<Transaction> transactions, int month, int year) async {
    try {
      final StringBuffer csvData = StringBuffer();
      // Format tanpa titik ribuan agar mudah dijumlahkan oleh rumus Excel
      final formatCurrency =
          NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);
      final formatDate = DateFormat('yyyy-MM-dd HH:mm');

      // 1. Tulis Header Kolom
      csvData.writeln('Tanggal,Kategori,Tipe,Catatan,Nominal');

      // 2. Tulis Baris Data
      for (var txn in transactions) {
        final isIncome = txn.category.value?.type == 'income';
        final typeStr = isIncome ? 'Pemasukan' : 'Pengeluaran';
        final categoryName = txn.category.value?.name ?? 'Lainnya';

        // Hilangkan koma pada catatan agar tidak merusak kolom CSV
        final note = txn.note?.replaceAll(',', ' ') ?? '';
        // Bersihkan angka dari pemisah ribuan
        final amountStr = formatCurrency.format(txn.amount).replaceAll('.', '');

        csvData.writeln(
            '${formatDate.format(txn.date)},$categoryName,$typeStr,$note,$amountStr');
      }

      // 3. Simpan ke Cache Perangkat
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/Laporan_FinTrack_${month}_$year.csv';
      final file = File(filePath);
      await file.writeAsString(csvData.toString());

      // 4. Buka Dialog Share bawaan OS
      await Share.shareXFiles([XFile(filePath)],
          text: 'Laporan CSV FinTrack Pro - Bulan $month Tahun $year');
    } catch (e) {
      // Error akan ditangkap secara sunyi untuk menjaga stabilitas UI
    }
  }
}
