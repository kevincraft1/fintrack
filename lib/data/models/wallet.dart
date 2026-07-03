import 'package:isar/isar.dart';

part 'wallet.g.dart';

@collection
class Wallet {
  Id id = Isar.autoIncrement;

  late String name;
  late String iconName;
  double initialBalance = 0.0;
  double balance = 0.0;
}
