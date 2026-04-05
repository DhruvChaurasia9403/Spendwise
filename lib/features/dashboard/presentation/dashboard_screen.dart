import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../transactions/presentation/add_transaction_sheet.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final transactionsAsync = ref.watch(transactionNotifierProvider);
    final profileAsync = ref.watch(profileNotifierProvider);
    final userName = profileAsync.valueOrNull?.name ?? 'User';

    final textColor = AppTheme.textColor(context);
    final textDimColor = AppTheme.textDimColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final premiumGreen = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    final premiumRed = isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.brandPurple.withAlpha(76),
                      child: Text(profileAsync.valueOrNull?.avatar ?? '👤', style: const TextStyle(fontSize: 26)),
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
                  ],
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: -0.1),

              const SizedBox(height: 30),


              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Balance', style: TextStyle(color: textDimColor, fontSize: 16, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.formatCurrency(summary.balance),
                      style: TextStyle(color: textColor, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1),
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

              Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.5))
                  .animate().fade(delay: 200.ms),
              const SizedBox(height: 16),

              Expanded(
                child: transactionsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => const Center(child: Text('Failed to load data')),
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return Center(
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
                      ).animate().fade(delay: 300.ms).scale(begin: const Offset(0.9, 0.9));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 160),
                      physics: const BouncingScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];

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
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 75, right: 4),
        child: FloatingActionButton(
          backgroundColor: isDark ? AppTheme.brandPurple.withAlpha(230) : AppTheme.brandPurple,
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withAlpha(80), width: 1.5),
          ),
          onPressed: () {
            showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const AddTransactionSheet());
          },
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        )

            .animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(end: 1.05, duration: 1.5.seconds, curve: Curves.easeInOut)
            .shimmer(duration: 2.seconds, color: Colors.white.withAlpha(100)),
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
}