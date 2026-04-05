import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../dashboard/providers/selected_month_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

part 'insights_provider.g.dart';

class InsightsData {
  final String topCategory;
  final Map<String, double> categoryTotals;
  final List<double> dailyTrend;
  final List<double> weeklyTrend;

  InsightsData({
    required this.topCategory,
    required this.categoryTotals,
    required this.dailyTrend,
    required this.weeklyTrend,
  });
}

@riverpod
AsyncValue<InsightsData> insights(InsightsRef ref) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  if (transactionsAsync is AsyncLoading) return const AsyncValue.loading();
  if (transactionsAsync is AsyncError) return AsyncValue.error(transactionsAsync.error!, transactionsAsync.stackTrace!);

  final transactions = transactionsAsync.valueOrNull ?? [];

  // 1. Watch the global selected month
  final selectedMonth = ref.watch(selectedMonthProvider);

  // 2. Filter using the selected month instead of DateTime.now()
  final currentMonthExpenses = transactions.where((tx) =>
  tx.isExpense &&
      tx.date.month == selectedMonth.month &&
      tx.date.year == selectedMonth.year
  ).toList();

  final Map<String, double> totals = {};
  double maxSpend = 0;
  String topCat = '';

  for (var tx in currentMonthExpenses) {
    totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    if (totals[tx.category]! > maxSpend) {
      maxSpend = totals[tx.category]!;
      topCat = tx.category;
    }
  }

  final List<double> daily = List.filled(7, 0.0);
  final List<double> weekly = List.filled(4, 0.0);

  for (var tx in currentMonthExpenses) {
    int weekdayIndex = tx.date.weekday - 1;
    daily[weekdayIndex] += tx.amount;

    int weekIndex = (tx.date.day - 1) ~/ 7;
    if (weekIndex > 3) weekIndex = 3;
    weekly[weekIndex] += tx.amount;
  }

  return AsyncValue.data(InsightsData(
    topCategory: topCat,
    categoryTotals: totals,
    dailyTrend: daily,
    weeklyTrend: weekly,
  ));
}