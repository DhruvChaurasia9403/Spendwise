import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../transactions/providers/transaction_provider.dart';

part 'dashboard_providers.g.dart';

class DashboardSummary {
  final double balance;
  final double income;
  final double expenses;

  DashboardSummary({
    required this.balance,
    required this.income,
    required this.expenses,
  });
}

@riverpod
AsyncValue<DashboardSummary> dashboardSummary(DashboardSummaryRef ref) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  return transactionsAsync.whenData((transactions) {
    double income = 0;
    double expenses = 0;

    for (var tx in transactions) {
      if (tx.isExpense) {
        expenses += tx.amount;
      } else {
        income += tx.amount;
      }
    }

    return DashboardSummary(
      balance: income - expenses,
      income: income,
      expenses: expenses,
    );
  });
}