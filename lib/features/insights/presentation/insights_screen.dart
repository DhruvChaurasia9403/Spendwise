import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/glass_card.dart';
import '../providers/insights_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  bool _showLineChart = false;
  int _timeView = 0;

  @override
  Widget build(BuildContext context) {
    final insightsAsync = ref.watch(insightsProvider);
    final textColor = AppTheme.textColor(context);
    final dimColor = AppTheme.textDimColor(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Insights',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ).animate().fade(duration: 400.ms).slideX(begin: -0.1),
            const SizedBox(height: 24),
            insightsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: AppTheme.brandPurple,
                ),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Error: $err',
                  style: TextStyle(color: textColor),
                ),
              ),
              data: (data) {
                final totalSpend =
                data.categoryTotals.values.fold(0.0, (sum, item) => sum + item);
                final hasData = totalSpend > 0;
                final chartData =
                _timeView == 0 ? data.dailyTrend : data.weeklyTrend;

                return Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Highest Spending',
                                  style: TextStyle(
                                    color: dimColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hasData ? data.topCategory : 'No Data',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.expenseRed
                                    .withAlpha((0.1 * 255).toInt()),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                hasData
                                    ? Icons.local_fire_department_rounded
                                    : Icons.hourglass_empty_rounded,
                                color: AppTheme.expenseRed,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                      const SizedBox(height: 32),
                      Text(
                        'Spending Breakdown',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fade(delay: 200.ms),
                      const SizedBox(height: 16),
                      GlassCard(
                        height: 320,
                        padding: const EdgeInsets.all(20),
                        child: hasData
                            ? _buildPieChart(
                            data.categoryTotals, totalSpend, dimColor)
                            : _buildEmptyState(
                          context,
                          Icons.pie_chart_outline_rounded,
                          'Log more expenses to generate your breakdown.',
                        ),
                      )
                          .animate()
                          .fade(delay: 300.ms)
                          .scale(begin: const Offset(0.95, 0.95)),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trend Analysis',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.glassColor(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.glassBorder(context),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildTimeToggle(
                                        0, 'Days', textColor, dimColor),
                                    _buildTimeToggle(
                                        1, 'Weeks', textColor, dimColor),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => setState(
                                        () => _showLineChart = !_showLineChart),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.brandPurple
                                        .withAlpha((0.15 * 255).toInt()),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.brandPurple
                                          .withAlpha((0.3 * 255).toInt()),
                                    ),
                                  ),
                                  child: Icon(
                                    _showLineChart
                                        ? Icons.show_chart_rounded
                                        : Icons.bar_chart_rounded,
                                    color: AppTheme.brandPurple,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).animate().fade(delay: 400.ms),
                      const SizedBox(height: 16),
                      GlassCard(
                        height: 280,
                        padding: const EdgeInsets.only(
                          top: 30,
                          bottom: 16,
                          left: 16,
                          right: 24,
                        ),
                        child: hasData && chartData.any((v) => v > 0)
                            ? (_showLineChart
                            ? _buildLineChart(chartData, dimColor)
                            : _buildBarChart(chartData, dimColor))
                            : _buildEmptyState(
                          context,
                          Icons.trending_up_rounded,
                          'Not enough data points yet to plot a trend.',
                        ),
                      )
                          .animate()
                          .fade(delay: 500.ms)
                          .scale(begin: const Offset(0.95, 0.95)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeToggle(
      int index, String label, Color textColor, Color dimColor) {
    final isSelected = _timeView == index;

    return GestureDetector(
      onTap: () => setState(() => _timeView = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : dimColor,
            fontWeight:
            isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: AppTheme.textDimColor(context)
                .withAlpha((0.3 * 255).toInt()),
          ),
          const SizedBox(height: 16),
          Text(
            'No Data Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textDimColor(context),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
      Map<String, double> categoryTotals,
      double totalSpend,
      Color dimColor) {
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 50,
        sections: () {
          final sliceColors = [
            AppTheme.brandPurple,
            const Color(0xFFF472B6),
            const Color(0xFF38BDF8),
            const Color(0xFF34D399),
            const Color(0xFFFBBF24),
            const Color(0xFFF87171),
          ];

          var colorIndex = 0;

          return categoryTotals.entries.map((entry) {
            final color =
            sliceColors[colorIndex % sliceColors.length];
            colorIndex++;

            final percentage =
            (entry.value / totalSpend * 100).toStringAsFixed(0);

            return PieChartSectionData(
              value: entry.value,
              title: '${entry.key}\n$percentage%',
              color: color,
              radius: 80,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                shadows: [
                  Shadow(color: Colors.black54, blurRadius: 4)
                ],
              ),
            );
          }).toList();
        }(),
      ),
    );
  }

  FlTitlesData _buildTitles(Color dimColor) {
    return FlTitlesData(
      show: true,
      topTitles:
      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles:
      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            var label = '';

            if (_timeView == 0) {
              const days = [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun'
              ];
              if (index >= 0 && index < days.length) {
                label = days[index];
              }
            } else {
              const weeks = ['W1', 'W2', 'W3', 'W4'];
              if (index >= 0 && index < weeks.length) {
                label = weeks[index];
              }
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                label,
                style: TextStyle(
                  color: dimColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 45,
          getTitlesWidget: (value, meta) {
            if (value == 0) return const SizedBox();

            final text = value >= 1000
                ? '${(value / 1000).toStringAsFixed(1)}k'
                : value.toInt().toString();

            return Text(
              '₹$text',
              style: TextStyle(
                color: dimColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
    );
  }

  FlGridData _buildGrid(Color dimColor) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 1000,
      getDrawingHorizontalLine: (value) => FlLine(
        color: dimColor.withAlpha((0.15 * 255).toInt()),
        strokeWidth: 1,
        dashArray: [5, 5],
      ),
    );
  }

  Widget _buildBarChart(List<double> trend, Color dimColor) {
    return BarChart(
      BarChartData(
        gridData: _buildGrid(dimColor),
        titlesData: _buildTitles(dimColor),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor:
            AppTheme.brandPurple.withAlpha(230),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                AppFormatters.formatCurrency(rod.toY),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        barGroups: trend
            .asMap()
            .entries
            .map(
              (e) => BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: AppTheme.brandPurple,
                width: 22,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildLineChart(List<double> trend, Color dimColor) {
    return LineChart(
      LineChartData(
        gridData: _buildGrid(dimColor),
        titlesData: _buildTitles(dimColor),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor:
            AppTheme.brandPurple.withAlpha(230),
            getTooltipItems: (touchedSpots) {
              return touchedSpots
                  .map(
                    (spot) => LineTooltipItem(
                  AppFormatters.formatCurrency(spot.y),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  .toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: trend
                .asMap()
                .entries
                .map((e) => FlSpot(
                e.key.toDouble(), e.value))
                .toList(),
            isCurved: true,
            color: AppTheme.brandPurple,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.brandPurple
                      .withAlpha((0.4 * 255).toInt()),
                  AppTheme.brandPurple
                      .withAlpha(0),
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