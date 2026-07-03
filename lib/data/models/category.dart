import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  late String name;
  late String iconName;
  late String type; // 'income', 'expense', 'transfer'
  String colorHex = '#3B82F6'; // Properti baru untuk kustomisasi warna
}
