import 'package:isar/isar.dart';
import 'category.dart';
import 'wallet.dart';
import 'debt.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late double amount;

  @Index()
  late DateTime date;

  String? note;
  final category = IsarLink<Category>();
  final wallet = IsarLink<Wallet>();
  final toWallet = IsarLink<Wallet>();

  final debt = IsarLink<Debt>();
}
