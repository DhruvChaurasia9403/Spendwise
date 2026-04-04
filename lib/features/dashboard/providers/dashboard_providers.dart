import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../profile/providers/profile_provider.dart';

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
DashboardSummary dashboardSummary(DashboardSummaryRef ref) {
  final transactions = ref.watch(transactionNotifierProvider).valueOrNull ?? [];
  final profile = ref.watch(profileNotifierProvider).valueOrNull;

  final baseIncome = profile?.targetIncome ?? 0.0;

  double addedIncome = 0;
  double expenses = 0;

  for (var tx in transactions) {
    if (tx.isExpense) {
      expenses += tx.amount;
    } else {
      addedIncome += tx.amount;
    }
  }

  final totalIncome = baseIncome + addedIncome;
  final totalBalance = totalIncome - expenses;

  return DashboardSummary(
    balance: totalBalance,
    income: totalIncome,
    expenses: expenses,
  );
}