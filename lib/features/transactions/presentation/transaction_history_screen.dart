import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/glass_text_field.dart';
import '../providers/transaction_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../dashboard/providers/selected_month_provider.dart';
import '../../profile/providers/archive_provider.dart';
import 'add_transaction_sheet.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionNotifierProvider);
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final archives = ref.watch(archiveNotifierProvider).valueOrNull ?? [];

    final textColor = AppTheme.textColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final premiumRed = isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);
    final premiumGreen = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);

    final now = DateTime.now();
    final isCurrentMonth = selectedMonth.month == now.month && selectedMonth.year == now.year;

    double displayBaseIncome = profile?.targetIncome ?? 0.0;

    if (!isCurrentMonth) {
      var pastArchive = archives.where((a) => a.month == selectedMonth.month && a.year == selectedMonth.year).firstOrNull;

      if (pastArchive != null) {
        double historicalAddedIncome = 0;
        final pastTxs = transactionsAsync.valueOrNull?.where((tx) =>
        tx.date.month == selectedMonth.month && tx.date.year == selectedMonth.year) ?? [];

        for (var tx in pastTxs) {
          if (!tx.isExpense) historicalAddedIncome += tx.amount;
        }

        displayBaseIncome = pastArchive.totalIncome - historicalAddedIncome;
      }
    }

    final showBaseIncome = displayBaseIncome > 0 &&
        (_filterType == 'All' || _filterType == 'Income') &&
        (_searchQuery.isEmpty || 'salary base income'.contains(_searchQuery.toLowerCase()));

    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text('All Transactions', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                GlassTextField(
                  hintText: 'Search by category or notes...',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['All', 'Income', 'Expense'].map((type) {
                    final isSelected = _filterType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _filterType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.brandPurple : AppTheme.glassColor(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppTheme.brandPurple : AppTheme.glassBorder(context)),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Center(child: Text('Error loading transactions')),
              data: (allTransactions) {
                final filtered = allTransactions.where((tx) {
                  final matchesMonth = tx.date.month == selectedMonth.month && tx.date.year == selectedMonth.year;

                  final matchesType = _filterType == 'All' ||
                      (_filterType == 'Income' && !tx.isExpense) ||
                      (_filterType == 'Expense' && tx.isExpense);

                  final matchesSearch = _searchQuery.isEmpty ||
                      tx.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (tx.notes != null && tx.notes!.toLowerCase().contains(_searchQuery.toLowerCase()));

                  return matchesMonth && matchesType && matchesSearch;
                }).toList();

                if (filtered.isEmpty && !showBaseIncome) {
                  return Center(child: Text('No transactions match your search.', style: TextStyle(color: AppTheme.textDimColor(context))));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length + (showBaseIncome ? 1 : 0),
                  itemBuilder: (context, index) {

                    if (showBaseIncome && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Manage your Base Income in the Profile tab')),
                            );
                          },
                          child: GlassCard(
                            opacity: isDark ? 0.05 : 0.4,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Base Income', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                                      Text(isCurrentMonth ? 'Fixed Profile Target' : 'Archived Historical Income', style: TextStyle(color: AppTheme.textDimColor(context), fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '+${AppFormatters.formatCurrency(displayBaseIncome)}',
                                  style: TextStyle(color: premiumGreen, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final tx = filtered[showBaseIncome ? index - 1 : index];

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
                        onDismissed: (_) {
                          ref.read(transactionNotifierProvider.notifier).deleteTransaction(tx.id);
                        },
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tx.category, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                                      Text(AppFormatters.formatDate(tx.date), style: TextStyle(color: AppTheme.textDimColor(context), fontSize: 12)),
                                      if (tx.notes != null && tx.notes!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(tx.notes!, style: TextStyle(color: AppTheme.textDimColor(context), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${tx.isExpense ? "-" : "+"}${AppFormatters.formatCurrency(tx.amount)}',
                                  style: TextStyle(color: tx.isExpense ? premiumRed : premiumGreen, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}