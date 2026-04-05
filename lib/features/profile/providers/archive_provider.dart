import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../history/models/monthly_summary.dart';
import '../../transactions/repositories/transaction_repository.dart';
import '../../transactions/models/transaction.dart';

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

    final existingSummary = await db.collection<MonthlySummary>()
        .filter()
        .monthEqualTo(month)
        .and()
        .yearEqualTo(year)
        .findFirst();

    final summary = existingSummary ?? MonthlySummary();
    summary.month = month;
    summary.year = year;
    summary.totalIncome = income;
    summary.totalExpenses = expenses;
    summary.topCategory = topCategory;

    await db.writeTxn(() async {
      await db.collection<MonthlySummary>().put(summary);
    });

    ref.invalidateSelf();
  }

  Future<void> autoArchivePastMonths({required double oldBaseIncome, required List<Transaction> transactions}) async {
    final db = ref.read(databaseServiceProvider).db;
    final now = DateTime.now();

    final pastDates = transactions
        .where((tx) => tx.date.isBefore(DateTime(now.year, now.month)))
        .map((tx) => DateTime(tx.date.year, tx.date.month))
        .toSet();

    for (var date in pastDates) {
      final exists = await db.collection<MonthlySummary>()
          .filter()
          .monthEqualTo(date.month)
          .and()
          .yearEqualTo(date.year)
          .findFirst();

      if (exists == null) {
        double expenses = 0;
        double addedIncome = 0;
        Map<String, double> categories = {};

        for (var tx in transactions) {
          if (tx.date.month == date.month && tx.date.year == date.year) {
            if (tx.isExpense) {
              expenses += tx.amount;
              categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
            } else {
              addedIncome += tx.amount;
            }
          }
        }

        String topCat = categories.isEmpty ? 'None' : categories.entries.reduce((a, b) => a.value > b.value ? a : b).key;

        final summary = MonthlySummary()
          ..month = date.month
          ..year = date.year
          ..totalIncome = oldBaseIncome + addedIncome
          ..totalExpenses = expenses
          ..topCategory = topCat;

        await db.writeTxn(() async {
          await db.collection<MonthlySummary>().put(summary);
        });
      }
    }
    ref.invalidateSelf();
  }
}