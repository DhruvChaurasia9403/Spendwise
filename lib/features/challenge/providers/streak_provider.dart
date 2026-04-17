import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../transactions/providers/transaction_provider.dart';

part 'streak_provider.g.dart';
@riverpod
AsyncValue<int> noSpendStreak(NoSpendStreakRef ref) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  return transactionsAsync.whenData((transactions) {
    final expenseDates = transactions
        .where((tx) => tx.isExpense)
        .map((tx) => DateTime(tx.date.year, tx.date.month, tx.date.day))
        .toSet();

    if (expenseDates.isEmpty) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    final currentMonth = checkDate.month;

    while (!expenseDates.contains(checkDate) && checkDate.month == currentMonth) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  });
}