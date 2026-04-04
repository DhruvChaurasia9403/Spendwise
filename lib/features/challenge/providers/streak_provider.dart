import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../transactions/providers/transaction_provider.dart';

part 'streak_provider.g.dart';
@riverpod
AsyncValue<int> noSpendStreak(NoSpendStreakRef ref) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  return transactionsAsync.whenData((transactions) {
    // 1. Get all dates where an expense occurred
    final expenseDates = transactions
        .where((tx) => tx.isExpense)
        .map((tx) => DateTime(tx.date.year, tx.date.month, tx.date.day))
        .toSet();

    int streak = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    // 2. Count backwards from today. Break the loop when we hit an expense date.
    while (!expenseDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  });
}