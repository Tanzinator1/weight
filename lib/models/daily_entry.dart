import 'package:hive/hive.dart';

part 'daily_entry.g.dart';

@HiveType(typeId: 0)
class DailyEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double weight;

  @HiveField(2)
  double sleepHours;

  @HiveField(3)
  int caloriesBreakfast;

  @HiveField(4)
  int caloriesLunch;

  @HiveField(5)
  int caloriesDinner;

  @HiveField(6)
  int caloriesSnack;

  @HiveField(7)
  bool workoutCompleted;

  DailyEntry({
    required this.date,
    required this.weight,
    required this.sleepHours,
    required this.caloriesBreakfast,
    required this.caloriesLunch,
    required this.caloriesDinner,
    required this.caloriesSnack,
    required this.workoutCompleted,
  });
}
