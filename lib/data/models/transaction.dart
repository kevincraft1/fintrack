import 'package:isar/isar.dart';
import 'category.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late double amount;
  late DateTime date;
  String? note;

  // Relasi ke tabel Category
  final category = IsarLink<Category>();
}
