import 'package:isar/isar.dart';
import 'category.dart';

part 'budget.g.dart';

@collection
class Budget {
  Id id = Isar.autoIncrement;

  late double limitAmount;
  late int month;
  late int year;

  final category = IsarLink<Category>();
}
