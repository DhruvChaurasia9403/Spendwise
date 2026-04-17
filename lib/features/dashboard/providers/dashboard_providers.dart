import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/selected_month_provider.dart';
import '../../profile/providers/archive_provider.dart';

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
  final selectedMonth = ref.watch(selectedMonthProvider);
  final archives = ref.watch(archiveNotifierProvider).valueOrNull ?? [];

  final now = DateTime.now();
  final isCurrentMonth = selectedMonth.month == now.month && selectedMonth.year == now.year;

  double addedIncome = 0;
  double expenses = 0;

  for (var tx in transactions) {
    if (tx.date.month == selectedMonth.month && tx.date.year == selectedMonth.year) {
      if (tx.isExpense) {
        expenses += tx.amount;
      } else {
        addedIncome += tx.amount;
      }
    }
  }

  double totalIncome = 0;

  if (isCurrentMonth) {
    final baseIncome = profile?.targetIncome ?? 0.0;
    totalIncome = baseIncome + addedIncome;
  } else {
    var pastArchive = archives.where((a) => a.month == selectedMonth.month && a.year == selectedMonth.year).firstOrNull;

    if (pastArchive != null) {
      totalIncome = pastArchive.totalIncome;
    } else {
      final baseIncome = profile?.targetIncome ?? 0.0;
      totalIncome = baseIncome + addedIncome;
    }
  }

  final totalBalance = totalIncome - expenses;

  return DashboardSummary(
    balance: totalBalance,
    income: totalIncome,
    expenses: expenses,
  );
}