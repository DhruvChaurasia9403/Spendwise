import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../history/models/monthly_summary.dart';
import '../providers/profile_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../providers/archive_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _showLineChart = true;
  final List<String> availableAvatars = const ['👤','🚀','🦊','🧠','💼','🌈','🔥','👑'];

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;

    final archives = ref.watch(archiveNotifierProvider).valueOrNull ?? [];

    final transactionsAsync = ref.watch(transactionNotifierProvider);
    double currentMonthSpend = 0;
    final now = DateTime.now();

    if (transactionsAsync is AsyncData) {
      for (var tx in transactionsAsync.value!) {
        if (tx.isExpense && tx.date.month == now.month && tx.date.year == now.year) {
          currentMonthSpend += tx.amount;
        }
      }
    }

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
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Profile', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)),
                      IconButton(
                        onPressed: () => _showPremiumEditSheet(context, ref, profile),
                        icon: Icon(Icons.settings_rounded, color: AppTheme.brandPurple, size: 28),
                      )
                    ],
                  ).animate().fade().slideX(begin: -0.1),
                  const SizedBox(height: 24),

                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                              BoxShadow(color: AppTheme.brandPurple.withAlpha(127), blurRadius: 20, spreadRadius: -5)
                            ]),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppTheme.brandPurple.withAlpha(76),
                              child: Text(profile.avatar, style: const TextStyle(fontSize: 40)),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(profile.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.incomeGreen.withAlpha(38),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppTheme.incomeGreen.withAlpha(76)),
                                    ),
                                    child: Text(
                                      'Income: ${AppFormatters.formatCurrency(profile.targetIncome)}',
                                      style: const TextStyle(color: AppTheme.incomeGreen, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ]
                            ),
                          ),
                        ]
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  Text('History Vault', style: TextStyle(color: textDimColor, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.2)).animate().fade(delay: 200.ms),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 110,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildArchiveCard(
                              context: context,
                              title: '${_getMonthName(now.month)} ${now.year}',
                              amount: currentMonthSpend,
                              isCurrent: true
                          ),
                          ...archives.map((archive) => _buildArchiveCard(
                              context: context,
                              title: '${_getMonthName(archive.month)} ${archive.year}',
                              amount: archive.totalExpenses,
                              isCurrent: false
                          )),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 300.ms).slideX(begin: 0.1),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Yearly Analytics', style: TextStyle(color: textDimColor, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                      GestureDetector(
                        onTap: () => setState(() => _showLineChart = !_showLineChart),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.brandPurple.withAlpha(38),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.brandPurple.withAlpha(76)),
                          ),
                          child: Icon(_showLineChart ? Icons.bar_chart_rounded : Icons.show_chart_rounded, color: AppTheme.brandPurple, size: 18),
                        ),
                      )
                    ],
                  ).animate().fade(delay: 400.ms),
                  const SizedBox(height: 12),

                  GlassCard(
                    height: 250,
                    padding: const EdgeInsets.only(top: 30, bottom: 16, left: 10, right: 24),
                    child: _showLineChart
                        ? _buildYearlyLineChart(textColor, textDimColor, archives, currentMonthSpend, now.month)
                        : _buildYearlyBarChart(textColor, textDimColor, archives, currentMonthSpend, now.month),
                  ).animate().fade(delay: 500.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 32),

                  Text('Preferences', style: TextStyle(color: textDimColor, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.2)).animate().fade(delay: 600.ms),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.brandPurple.withAlpha(50), shape: BoxShape.circle),
                        child: Icon(isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppTheme.brandPurple),
                      ),
                      title: Text('Appearance', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                      subtitle: Text(isDarkMode ? 'Dark Mode' : 'Light Mode', style: TextStyle(color: textDimColor, fontSize: 13)),
                      trailing: Switch(
                        value: isDarkMode,
                        activeColor: AppTheme.brandPurple,
                        onChanged: (_) => ref.read(themeNotifierProvider.notifier).toggleTheme(),
                      ),
                    ),
                  ).animate().fade(delay: 700.ms),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArchiveCard({required BuildContext context, required String title, required double amount, required bool isCurrent}) {
    final textColor = AppTheme.textColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppTheme.glassColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent ? AppTheme.brandPurple.withAlpha(isDark ? 150 : 100) : AppTheme.glassBorder(context),
          width: isCurrent ? 2 : 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.brandPurple.withAlpha(50), borderRadius: BorderRadius.circular(4)),
                  child: const Text('LIVE', style: TextStyle(color: AppTheme.brandPurple, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text('- ${AppFormatters.formatCurrency(amount)}', style: const TextStyle(color: AppTheme.expenseRed, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );

    if (isCurrent) {
      return card.animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3.seconds, color: Colors.white.withAlpha(30));
    }
    return card;
  }

  List<double> _getYearlyData(List<MonthlySummary> archives, double liveSpend, int liveMonth) {
    List<double> monthlyData = List.filled(12, 0.0);
    int currentYear = DateTime.now().year;

    for (var archive in archives) {
      if (archive.year == currentYear && archive.month >= 1 && archive.month <= 12) {
        monthlyData[archive.month - 1] = archive.totalExpenses;
      }
    }

    monthlyData[liveMonth - 1] = liveSpend;

    return monthlyData;
  }

  Widget _buildYearlyLineChart(Color textColor, Color dimColor, List<MonthlySummary> archives, double liveSpend, int liveMonth) {
    final data = _getYearlyData(archives, liveSpend, liveMonth);
    final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5000, getDrawingHorizontalLine: (v) => FlLine(color: dimColor.withAlpha(30), dashArray: [5, 5])),
        titlesData: _buildYearlyTitles(dimColor),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppTheme.brandPurple.withAlpha(230),
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) => LineTooltipItem(AppFormatters.formatCurrency(spot.y), const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.brandPurple,
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppTheme.brandPurple.withAlpha(100), AppTheme.brandPurple.withAlpha(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyBarChart(Color textColor, Color dimColor, List<MonthlySummary> archives, double liveSpend, int liveMonth) {
    final data = _getYearlyData(archives, liveSpend, liveMonth);
    final barGroups = data.asMap().entries.map((e) => BarChartGroupData(
        x: e.key,
        barRods: [BarChartRodData(toY: e.value, color: AppTheme.brandPurple, width: 14, borderRadius: BorderRadius.circular(4))]
    )).toList();

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5000, getDrawingHorizontalLine: (v) => FlLine(color: dimColor.withAlpha(30), dashArray: [5, 5])),
        titlesData: _buildYearlyTitles(dimColor),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppTheme.brandPurple.withAlpha(230),
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(AppFormatters.formatCurrency(rod.toY), const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }

  FlTitlesData _buildYearlyTitles(Color dimColor) {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 45, getTitlesWidget: (v, m) {
        if (v == 0) return const SizedBox();
        return Text('₹${(v/1000).toInt()}k', style: TextStyle(color: dimColor, fontSize: 10, fontWeight: FontWeight.bold));
      })),
      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
        const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
        if (v.toInt() < 0 || v.toInt() >= months.length) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(months[v.toInt()], style: TextStyle(color: dimColor, fontSize: 11, fontWeight: FontWeight.bold)),
        );
      })),
    );
  }

  void _showPremiumEditSheet(BuildContext context, WidgetRef ref, dynamic profile) {
    String selectedAvatar = profile.avatar;
    final nameController = TextEditingController(text: profile.name);
    final incomeController = TextEditingController(text: profile.targetIncome.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppTheme.textColor(context);

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
                color: isDark ? AppTheme.darkBgMain.withAlpha(204) : Colors.white.withAlpha(230),
                border: Border(top: BorderSide(color: Colors.white.withAlpha(51), width: 1)),
              ),
              padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: bottomInset + 24),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withAlpha(76), borderRadius: BorderRadius.circular(10)))),
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
                            color: selectedAvatar == avatar ? AppTheme.brandPurple.withAlpha(isDark ? 102 : 51) : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedAvatar == avatar ? AppTheme.brandPurple : Colors.grey.withAlpha(51),
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
                      fillColor: isDark ? Colors.black12 : Colors.grey.withAlpha(25),
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
                      fillColor: isDark ? Colors.black12 : Colors.grey.withAlpha(25),
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
}