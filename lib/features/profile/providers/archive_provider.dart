import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../history/models/monthly_summary.dart';
import '../../transactions/repositories/transaction_repository.dart';

part 'archive_provider.g.dart';

@riverpod
class ArchiveNotifier extends _$ArchiveNotifier {
  @override
  Future<List<MonthlySummary>> build() async {
    final db = ref.read(databaseServiceProvider).db;

    return await db.collection<MonthlySummary>()
        .where()
        .sortByYearDesc()
        .thenByMonthDesc()
        .findAll();
  }

  Future<void> saveMonthToHistory(int month, int year, double income, double expenses, String topCategory) async {
    final db = ref.read(databaseServiceProvider).db;

    final summary = MonthlySummary()
      ..month = month
      ..year = year
      ..totalIncome = income
      ..totalExpenses = expenses
      ..topCategory = topCategory;

    await db.writeTxn(() async {
      await db.collection<MonthlySummary>().put(summary);
    });

    ref.invalidateSelf();
  }
}