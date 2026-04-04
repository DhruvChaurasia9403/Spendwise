import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/widgets/glass_card.dart';
import '../providers/insights_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Financial Insights',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),

              insightsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error loading insights: $err')),
                data: (data) => Expanded(
                  child: ListView(
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text('Highest Spending', style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(
                              data.topCategory,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text('Spending by Category', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 12),
                      GlassCard(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: data.categoryTotals.entries.map((entry) {
                              return PieChartSectionData(
                                value: entry.value,
                                title: entry.key,
                                color: Colors.white.withOpacity(0.3),
                                radius: 50,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text('Weekly Trend', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 12),
                      GlassCard(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: data.weeklyTrend.asMap().entries.map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value,
                                    color: Colors.white.withOpacity(0.4),
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}