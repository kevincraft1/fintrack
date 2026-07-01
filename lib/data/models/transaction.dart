import 'package:isar/isar.dart';
import 'category.dart';
import 'wallet.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late double amount;
  late DateTime date;
  String? note;

  // Relasi ke Kategori
  final category = IsarLink<Category>();

  // Relasi ke Dompet/Akun
  final wallet = IsarLink<Wallet>();
}
