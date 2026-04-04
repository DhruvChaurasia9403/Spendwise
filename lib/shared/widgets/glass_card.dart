import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final bool enableBlur;

  const GlassCard({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height,
    this.blur = AppTheme.glassBlur,
    this.opacity = AppTheme.glassOpacity,
    this.padding = const EdgeInsets.all(16),
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.glassColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder(context), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 20,
            spreadRadius: -5,
          )
        ],
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: enableBlur
          ? BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: container,
      )
          : container,
    );
  }
}