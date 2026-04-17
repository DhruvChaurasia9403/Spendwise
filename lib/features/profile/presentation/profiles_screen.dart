import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../history/models/monthly_summary.dart';
import '../providers/profile_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../providers/archive_provider.dart';
import '../../dashboard/providers/selected_month_provider.dart';

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
    final selectedMonth = ref.watch(selectedMonthProvider);

    final now = DateTime.now();
    final isCurrentMonth = selectedMonth.month == now.month && selectedMonth.year == now.year;

    double currentMonthSpend = 0;

    if (transactionsAsync is AsyncData) {
      for (var tx in transactionsAsync.value!) {
        if (tx.isExpense && tx.date.month == selectedMonth.month && tx.date.year == selectedMonth.year) {
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
            actions: [
              IconButton(
                onPressed: () => _showPremiumEditSheet(context, ref, profile, transactionsAsync),
                icon: const Icon(Icons.edit_rounded, size: 24),
                color: textColor,
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 120),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.brandPurple.withAlpha(100), width: 2),
                            boxShadow: [
                              BoxShadow(color: AppTheme.brandPurple.withAlpha(60), blurRadius: 24, spreadRadius: 2)
                            ]
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: AppTheme.brandPurple.withAlpha(50),
                          child: Text(profile.avatar, style: const TextStyle(fontSize: 42)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(profile.name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.incomeGreen.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.incomeGreen.withAlpha(80)),
                        ),
                        child: Text(
                          'Target Income: ${AppFormatters.formatCurrency(profile.targetIncome)}',
                          style: const TextStyle(color: AppTheme.incomeGreen, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 48),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('History Vault', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Your archived months', style: TextStyle(color: textDimColor, fontSize: 13)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        double currentIncome = profile.targetIncome;
                        double currentExp = 0;
                        Map<String, double> categories = {};

                        if (transactionsAsync is AsyncData) {
                          for (var tx in transactionsAsync.value!) {
                            if (tx.date.month == selectedMonth.month && tx.date.year == selectedMonth.year) {
                              if (tx.isExpense) {
                                currentExp += tx.amount;
                                categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
                              } else {
                                currentIncome += tx.amount;
                              }
                            }
                          }
                        }

                        String topCat = categories.isEmpty ? 'None' :
                        categories.entries.reduce((a, b) => a.value > b.value ? a : b).key;

                        ref.read(archiveNotifierProvider.notifier)
                            .saveMonthToHistory(selectedMonth.month, selectedMonth.year, currentIncome, currentExp, topCat);

                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${_getMonthName(selectedMonth.month)} archived successfully.'))
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.brandPurple.withAlpha(40),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.brandPurple.withAlpha(100)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.archive_outlined, size: 16, color: AppTheme.brandPurple),
                            const SizedBox(width: 6),
                            Text('Archive ${_getMonthName(selectedMonth.month)}', style: const TextStyle(color: AppTheme.brandPurple, fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.none,
                    children: [
                      _buildArchiveCard(
                          context: context,
                          title: '${_getMonthName(selectedMonth.month)} ${selectedMonth.year}',
                          amount: currentMonthSpend,
                          isCurrent: isCurrentMonth
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

                const SizedBox(height: 48),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Yearly Analytics', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w700)),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.glassColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.glassBorder(context)),
                      ),
                      child: Row(
                        children: [
                          _buildChartToggle(Icons.show_chart_rounded, true, isDarkMode),
                          _buildChartToggle(Icons.bar_chart_rounded, false, isDarkMode),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                GlassCard(
                  height: 280,
                  padding: const EdgeInsets.only(top: 32, bottom: 16, left: 12, right: 24),
                  child: _showLineChart
                      ? _buildYearlyLineChart(textColor, textDimColor, archives, currentMonthSpend, selectedMonth.month)
                      : _buildYearlyBarChart(textColor, textDimColor, archives, currentMonthSpend, selectedMonth.month),
                ),

                const SizedBox(height: 48),

                Text('Settings', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),

                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppTheme.brandPurple.withAlpha(40), borderRadius: BorderRadius.circular(12)),
                          child: Icon(isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppTheme.brandPurple, size: 22),
                        ),
                        title: Text('Appearance', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16)),
                        subtitle: Text(isDarkMode ? 'Dark Mode' : 'Light Mode', style: TextStyle(color: textDimColor, fontSize: 13)),
                        trailing: Switch(
                          value: isDarkMode,
                          activeColor: AppTheme.brandPurple,
                          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                          inactiveTrackColor: AppTheme.glassBorder(context),
                          onChanged: (_) => ref.read(themeNotifierProvider.notifier).toggleTheme(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fade(duration: 400.ms).slideY(begin: 0.05),
          ),
        );
      },
    );
  }

  Widget _buildChartToggle(IconData icon, bool isLine, bool isDark) {
    final isSelected = _showLineChart == isLine;
    return GestureDetector(
      onTap: () => setState(() => _showLineChart = isLine),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isSelected ? Colors.white : AppTheme.textDimColor(context), size: 18),
      ),
    );
  }

  Widget _buildArchiveCard({required BuildContext context, required String title, required double amount, required bool isCurrent}) {
    final textColor = AppTheme.textColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.brandPurple.withAlpha(20) : AppTheme.glassColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent ? AppTheme.brandPurple.withAlpha(150) : AppTheme.glassBorder(context),
          width: isCurrent ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCurrent)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.brandPurple, borderRadius: BorderRadius.circular(6)),
                  child: const Text('VIEWING', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                )
              else
                const SizedBox(height: 24),
              Text(title, style: TextStyle(color: isCurrent ? AppTheme.brandPurple : textDimColor(context), fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          Text(AppFormatters.formatCurrency(amount), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
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
        return Text('${(v/1000).toInt()}k', style: TextStyle(color: dimColor, fontSize: 11, fontWeight: FontWeight.w600));
      })),
      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
        const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
        if (v.toInt() < 0 || v.toInt() >= months.length) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(months[v.toInt()], style: TextStyle(color: dimColor, fontSize: 11, fontWeight: FontWeight.bold)),
        );
      })),
    );
  }

  Color textDimColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white60 : const Color(0xFF64748B);

  void _showPremiumEditSheet(BuildContext context, WidgetRef ref, dynamic profile, AsyncValue transactionsAsync) {
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
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBgMain.withAlpha(220) : Colors.white.withAlpha(240),
                border: Border(top: BorderSide(color: Colors.white.withAlpha(50), width: 1)),
              ),
              padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: bottomInset + 24),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withAlpha(100), borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 32),
                  Text('Edit Profile', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 32),

                  Text('Choose Avatar', style: TextStyle(color: textDimColor(context), fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: availableAvatars.map((avatar) => GestureDetector(
                        onTap: () => setSheetState(() => selectedAvatar = avatar),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(14),
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

                  const SizedBox(height: 32),

                  TextField(
                    controller: nameController,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      labelStyle: TextStyle(color: textDimColor(context)),
                      prefixIcon: Icon(Icons.person_outline_rounded, color: textDimColor(context)),
                      filled: true,
                      fillColor: isDark ? Colors.black12 : Colors.grey.withAlpha(25),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.brandPurple, width: 2)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: incomeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Base Monthly Income',
                      labelStyle: TextStyle(color: textDimColor(context)),
                      prefixIcon: Icon(Icons.currency_rupee_rounded, color: textDimColor(context)),
                      filled: true,
                      fillColor: isDark ? Colors.black12 : Colors.grey.withAlpha(25),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.brandPurple, width: 2)),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandPurple,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        final newIncome = double.tryParse(incomeController.text);
                        final newName = nameController.text.trim();
                        if (newIncome != null && newName.isNotEmpty) {

                          ref.read(archiveNotifierProvider.notifier).autoArchivePastMonths(
                            oldBaseIncome: profile.targetIncome,
                            transactions: transactionsAsync.valueOrNull ?? [],
                          );

                          ref.read(profileNotifierProvider.notifier).saveProfile(
                            name: newName,
                            income: newIncome,
                            isYearly: profile.isYearlyIncome,
                            avatar: selectedAvatar,
                          );
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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