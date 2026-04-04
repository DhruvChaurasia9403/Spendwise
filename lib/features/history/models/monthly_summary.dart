import 'package:isar/isar.dart';

part 'monthly_summary.g.dart';

@collection
class MonthlySummary {
  Id id = Isar.autoIncrement;

  late int month;
  late int year;
  late double totalIncome;
  late double totalExpenses;
  late String topCategory;
}