import 'package:isar/isar.dart';

part 'debt.g.dart';

@collection
class Debt {
  Id id = Isar.autoIncrement;

  late String personName; // Nama orang yang berhutang / kita hutangi
  late double totalAmount; // Total uang awal
  late double remainingAmount; // Sisa yang belum dilunasi
  late String
      type; // 'lend' (Piutang / Uang kita di orang) atau 'borrow' (Hutang / Kita pinjam uang)
  late DateTime dueDate; // Tanggal jatuh tempo
  late DateTime createdAt; // Tanggal dicatat
  String? note;
  bool isSettled = false; // Status Lunas (true/false)
}
