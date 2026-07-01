import 'package:isar/isar.dart';

part 'wallet.g.dart';

@collection
class Wallet {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late String iconName;

  // Saldo awal saat dompet dibuat (opsional)
  double initialBalance = 0.0;
}
