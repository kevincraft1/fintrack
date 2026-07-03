import 'package:isar/isar.dart';

part 'goal.g.dart';

@collection
class Goal {
  Id id = Isar.autoIncrement;

  late String name;
  late double targetAmount;
  late double savedAmount;
  late DateTime deadline;
  late DateTime createdAt;
  String colorHex = '#F59E0B'; // Default Emas
  String iconName = 'star';
}
