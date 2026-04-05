import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../transactions/presentation/add_transaction_sheet.dart';
import '../../transactions/presentation/transaction_history_screen.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/dashboard_providers.dart';
import '../../challenge/providers/streak_provider.dart';
import '../providers/selected_month_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final transactionsAsync = ref.watch(transactionNotifierProvider);
    final profileAsync = ref.watch(profileNotifierProvider);
    final streakAsync = ref.watch(noSpendStreakProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    final userName = profileAsync.valueOrNull?.name ?? 'User';

    final textColor = AppTheme.textColor(context);
    final textDimColor = AppTheme.textDimColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final premiumGreen = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    final premiumRed = isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Profile Card with Integrated Streak Badge
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.brandPurple.withAlpha(76),
                      child: Text(profileAsync.valueOrNull?.avatar ?? '', style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                          Text(
                            'Target Income: ${AppFormatters.formatCurrency(profileAsync.valueOrNull?.targetIncome ?? 0)}',
                            style: TextStyle(fontSize: 13, color: textDimColor),
                          ),
                        ],
                      ),
                    ),

                    // The New Compact Streak Badge
                    streakAsync.when(
                      loading: () => const SizedBox(width: 60, child: LinearProgressIndicator()),
                      error: (_, __) => const SizedBox(),
                      data: (streak) {
                        final isWinning = streak > 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: isWinning
                                  ? const Color(0xFFF59E0B).withAlpha(30)
                                  : AppTheme.glassBorder(context).withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isWinning
                                    ? const Color(0xFFF59E0B).withAlpha(100)
                                    : AppTheme.glassBorder(context),
                              )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isWinning ? Icons.local_fire_department_rounded : Icons.shield_outlined,
                                color: isWinning ? const Color(0xFFF59E0B) : textDimColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isWinning ? '$streak Day Streak' : 'No Streak',
                                style: TextStyle(
                                  color: isWinning ? const Color(0xFFFCD34D) : textDimColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: -0.1),

              const SizedBox(height: 30),

              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Balance', style: TextStyle(color: textDimColor, fontSize: 16, letterSpacing: 0.5)),

                        GestureDetector(
                          onTap: () => _showMonthPicker(context, ref, selectedMonth),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.brandPurple.withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    DateFormat('MMM yyyy').format(selectedMonth),
                                    style: const TextStyle(color: AppTheme.brandPurple, fontWeight: FontWeight.bold, fontSize: 13)
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.brandPurple, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.formatCurrency(summary.balance),
                      style: TextStyle(color: textColor, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1),
                    ),
                    const SizedBox(height: 24),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: summary.income > 0 ? (summary.expenses / summary.income).clamp(0.0, 1.0) : 0,
                        backgroundColor: AppTheme.glassBorder(context),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            (summary.expenses / (summary.income == 0 ? 1 : summary.income)) > 0.8
                                ? premiumRed
                                : premiumGreen
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${summary.income > 0 ? ((summary.expenses / summary.income) * 100).toStringAsFixed(1) : 0}% of target income spent',
                      style: TextStyle(color: textDimColor, fontSize: 12),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildIncomeExpenseColumn('Income', AppFormatters.formatCurrency(summary.income), premiumGreen, textDimColor),
                        _buildIncomeExpenseColumn('Expense', AppFormatters.formatCurrency(summary.expenses), premiumRed, textDimColor),
                      ],
                    ),
                  ],
                ),
              ).animate().fade(delay: 100.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.5))
                      .animate().fade(delay: 200.ms),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()));
                    },
                    child: const Text('View All', style: TextStyle(color: AppTheme.brandPurple, fontWeight: FontWeight.bold)),
                  ).animate().fade(delay: 200.ms),
                ],
              ),
              const SizedBox(height: 8),

              transactionsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => const Center(child: Text('Failed to load data')),
                data: (allTransactions) {
                  final monthTransactions = allTransactions.where((tx) =>
                  tx.date.month == selectedMonth.month &&
                      tx.date.year == selectedMonth.year
                  ).toList();

                  if (monthTransactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 64, color: textDimColor.withAlpha(70)),
                            const SizedBox(height: 16),
                            Text('No Transactions Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 8),
                            Text('Tap the + button to add your first expense.', style: TextStyle(color: textDimColor, fontSize: 13)),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: 300.ms).scale(begin: const Offset(0.9, 0.9));
                  }

                  final recentTransactions = monthTransactions.take(5).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: recentTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = recentTransactions[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: ValueKey(tx.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: premiumRed.withAlpha(204), borderRadius: BorderRadius.circular(24)),
                            child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 30),
                          ),
                          onDismissed: (_) => ref.read(transactionNotifierProvider.notifier).deleteTransaction(tx.id),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => AddTransactionSheet(transaction: tx),
                              );
                            },
                            child: GlassCard(
                              opacity: isDark ? 0.05 : 0.4,
                              blur: AppTheme.glassBlur,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(tx.category, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                                        if (tx.notes != null && tx.notes!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(tx.notes!, style: TextStyle(color: textDimColor, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${tx.isExpense ? "-" : "+"}${AppFormatters.formatCurrency(tx.amount)}',
                                    style: TextStyle(color: tx.isExpense ? premiumRed : premiumGreen, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).animate().fade(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110, right: 8),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.brandPurple.withAlpha(80),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: AppTheme.brandPurple,
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AddTransactionSheet(),
              );
            },
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseColumn(String label, String amount, Color color, Color dimColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: dimColor, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(amount, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
      ],
    );
  }

  void _showMonthPicker(BuildContext context, WidgetRef ref, DateTime currentSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<DateTime> months = List.generate(12, (index) {
      final now = DateTime.now();
      return DateTime(now.year, now.month - index);
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkBgMain : AppTheme.lightCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select Month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final monthDate = months[index];
                      final isSelected = monthDate.month == currentSelected.month && monthDate.year == currentSelected.year;

                      return ListTile(
                        title: Text(
                          DateFormat('MMMM yyyy').format(monthDate),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppTheme.brandPurple : AppTheme.textColor(context),
                          ),
                        ),
                        trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.brandPurple) : null,
                        onTap: () {
                          ref.read(selectedMonthProvider.notifier).setMonth(monthDate);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}