import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/glass_card.dart';
import '../providers/streak_provider.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(noSpendStreakProvider);

    return streakAsync.when(
      loading: () => const GlassCard(
        height: 100,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (err, _) => const SizedBox(),
      data: (streak) {

        final isWinning = streak > 0;

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

          opacity: isWinning ? 0.2 : 0.1,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isWinning
                      ? Colors.orangeAccent.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  isWinning ? '🔥' : '🧊',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No-Spend Streak',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isWinning
                          ? '$streak Days Strong!'
                          : 'Spend logged today.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}