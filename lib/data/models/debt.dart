import 'package:isar/isar.dart';
import 'wallet.dart';

part 'debt.g.dart';

@collection
class Debt {
  Id id = Isar.autoIncrement;

  late String personName;
  late double totalAmount;
  late double remainingAmount;
  late String type;
  late DateTime dueDate;
  late DateTime createdAt;
  String? note;
  bool isSettled = false;

  final wallet = IsarLink<Wallet>();
}
