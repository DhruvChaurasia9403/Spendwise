import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/glass_card.dart';
import '../providers/profile_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../core/theme/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  final List<String> availableAvatars = const ['👤','🚀','🦊','🧠','💼','🌈','🔥','👑'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final textColor = AppTheme.textColor(context);
    final textDimColor = AppTheme.textDimColor(context);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (profile) {
        if (profile == null) return const SizedBox();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Profile', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () => _showPremiumEditSheet(context, ref, profile),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                          BoxShadow(color: AppTheme.brandPurple.withAlpha((0.5 * 255).toInt()), blurRadius: 20, spreadRadius: -5)
                        ]),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: AppTheme.brandPurple.withAlpha((0.3 * 255).toInt()),
                          child: Text(profile.avatar, style: const TextStyle(fontSize: 45)),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(profile.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.incomeGreen.withAlpha((0.15 * 255).toInt()),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.incomeGreen.withAlpha((0.3 * 255).toInt())),
                            ),
                            child: Text(
                              'Income: ${AppFormatters.formatCurrency(profile.targetIncome)}',
                              style: const TextStyle(color: AppTheme.incomeGreen, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ]),
                      ),
                      Icon(Icons.edit_rounded, color: textDimColor.withAlpha((0.5 * 255).toInt()), size: 20),
                    ]),
                  ),
                ),

                const SizedBox(height: 32),

                Text('Preferences', style: TextStyle(color: textDimColor, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                const SizedBox(height: 12),

                GlassCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.brandPurple.withAlpha((0.2 * 255).toInt()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppTheme.brandPurple,
                      ),
                    ),
                    title: Text('Appearance', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    subtitle: Text(isDarkMode ? 'Dark Mode' : 'Light Mode', style: TextStyle(color: textDimColor, fontSize: 13)),
                    trailing: Switch(
                      value: isDarkMode,
                      activeColor: AppTheme.brandPurple,
                      onChanged: (_) => ref.read(themeNotifierProvider.notifier).toggleTheme(),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text('Lifetime Analytics', style: TextStyle(color: textDimColor, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                const SizedBox(height: 12),

                Consumer(builder: (context, ref, _) {
                  final allTxAsync = ref.watch(transactionNotifierProvider);
                  return allTxAsync.when(
                    data: (transactions) {
                      final expenses = transactions.where((tx) => tx.isExpense).toList();
                      final lifetimeSpend = expenses.fold(0.0, (s, tx) => s + tx.amount);

                      return Column(children: [
                        GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Total Tracked Spend', style: TextStyle(color: textDimColor, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(AppFormatters.formatCurrency(lifetimeSpend), style: const TextStyle(color: AppTheme.expenseRed, fontWeight: FontWeight.bold, fontSize: 22)),
                            ]),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.expenseRed.withAlpha((0.1 * 255).toInt()),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.trending_up_rounded, color: AppTheme.expenseRed),
                            )
                          ]),
                        ),
                        const SizedBox(height: 16),
                        if (expenses.isNotEmpty)
                          GlassCard(
                            height: 220,
                            padding: const EdgeInsets.only(top: 24, bottom: 10, left: 10, right: 24),
                            child: _buildLifetimeChart(expenses, context),
                          ),
                      ]);
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  );
                }),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        );
      },
    );
  }

  void _showPremiumEditSheet(BuildContext context, WidgetRef ref, dynamic profile) {
    String selectedAvatar = profile.avatar;
    final nameController = TextEditingController(text: profile.name);
    final incomeController = TextEditingController(text: profile.targetIncome.toString());
    final textColor = AppTheme.textColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (context, setSheetState) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkBgMain.withAlpha((0.8 * 255).toInt())
                    : Colors.white.withAlpha((0.9 * 255).toInt()),
                border: Border(top: BorderSide(color: Colors.white.withAlpha((0.2 * 255).toInt()), width: 1)),
              ),
              padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: bottomInset + 24),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withAlpha((0.3 * 255).toInt()), borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),
                  Text('Edit Profile', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  Text('Choose Avatar', style: TextStyle(color: AppTheme.textDimColor(context), fontSize: 14)),
                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: availableAvatars.map((avatar) => GestureDetector(
                        onTap: () => setSheetState(() => selectedAvatar = avatar),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedAvatar == avatar
                                ? AppTheme.brandPurple.withAlpha(((isDark ? 0.4 : 0.2) * 255).toInt())
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedAvatar == avatar
                                  ? AppTheme.brandPurple
                                  : Colors.grey.withAlpha((0.2 * 255).toInt()),
                              width: 2,
                            ),
                          ),
                          child: Text(avatar, style: const TextStyle(fontSize: 28)),
                        ),
                      )).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: nameController,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      labelStyle: TextStyle(color: AppTheme.textDimColor(context)),
                      prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.textDimColor(context)),
                      filled: true,
                      fillColor: isDark ? Colors.black12 : Colors.grey.withAlpha((0.1 * 255).toInt()),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.brandPurple, width: 2)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: incomeController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      labelText: 'Base Monthly Income',
                      labelStyle: TextStyle(color: AppTheme.textDimColor(context)),
                      prefixIcon: Icon(Icons.currency_rupee_rounded, color: AppTheme.textDimColor(context)),
                      filled: true,
                      fillColor: isDark ? Colors.black12 : Colors.grey.withAlpha((0.1 * 255).toInt()),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.brandPurple, width: 2)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandPurple,
                        elevation: 10,
                        shadowColor: AppTheme.brandPurple.withAlpha((0.5 * 255).toInt()),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        final newIncome = double.tryParse(incomeController.text);
                        final newName = nameController.text.trim();
                        if (newIncome != null && newName.isNotEmpty) {
                          ref.read(profileNotifierProvider.notifier).saveProfile(
                            name: newName,
                            income: newIncome,
                            isYearly: profile.isYearlyIncome,
                            avatar: selectedAvatar,
                          );
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLifetimeChart(List<dynamic> expenses, BuildContext context) {
    double x = 0;
    final spots = expenses.reversed.take(10).map((tx) => FlSpot(x++, tx.amount)).toList();

    if (spots.isEmpty) {
      return Center(child: Text('Not enough data', style: TextStyle(color: AppTheme.textDimColor(context))));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.brandPurple,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.brandPurple.withAlpha((0.4 * 255).toInt()),
                  AppTheme.brandPurple.withAlpha(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}