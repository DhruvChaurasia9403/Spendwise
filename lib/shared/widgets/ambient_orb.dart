import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AmbientOrb extends StatelessWidget {
  final Color color;
  final double size;
  final bool isBreathing;
  final Duration duration;

  const AmbientOrb({
    super.key,
    required this.color,
    required this.size,
    this.isBreathing = true,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    final orb = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withAlpha((0.6 * 255).toInt()),
            color.withAlpha((0.25 * 255).toInt()),
            color.withAlpha(0),
          ],
          stops: const [0, 0.5, 1],
        ),
      ),
    );

    return isBreathing
        ? orb
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
      begin: const Offset(1, 1),
      end: const Offset(1.6, 1.6),
      duration: duration,
      curve: Curves.easeInOut,
    )
        .fade(
      begin: 0.75,
      end: 1,
      duration: duration,
      curve: Curves.easeInOut,
    )
        : orb
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
      begin: const Offset(1, 1),
      end: const Offset(1.2, 1.2),
      duration: const Duration(seconds: 3),
    );
  }
}