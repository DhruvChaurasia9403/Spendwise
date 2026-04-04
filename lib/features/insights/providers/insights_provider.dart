import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/models/transaction.dart';

part 'insights_provider.g.dart';

class InsightsData {
  final Map<String, double> categoryTotals;
  final List<double> weeklyTrend; 
  final String topCategory;

  InsightsData({
    required this.categoryTotals,
    required this.weeklyTrend,
    required this.topCategory,
  });
}

@riverpod
AsyncValue<InsightsData> insights(InsightsRef ref) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  return transactionsAsync.whenData((transactions) {
    final Map<String, double> categoryMap = {};
    final List<double> trend = List.filled(7, 0.0);
    final now = DateTime.now();

    for (var tx in transactions) {
      if (tx.isExpense) {
        categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;        final difference = now.difference(tx.date).inDays;
        if (difference >= 0 && difference < 7) {
          trend[6 - difference] += tx.amount;
        }
      }
    }

    String topCat = 'None';
    if (categoryMap.isNotEmpty) {
      topCat = categoryMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    return InsightsData(
      categoryTotals: categoryMap,
      weeklyTrend: trend,
      topCategory: topCat,
    );
  });
}