import 'dart:ui';
import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/insights/presentation/insights_screen.dart';
import '../../features/profile/presentation/profiles_screen.dart';
import '../theme/app_theme.dart';
import '../../shared/widgets/ambient_orb.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final orbColor = AppTheme.orbColor(context);

    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: AmbientOrb(color: orbColor, size: 400, duration: const Duration(seconds: 5)),
          ),
          Positioned(
            bottom: -50,
            left: -150,
            child: AmbientOrb(color: AppTheme.brandPurple, size: 350, duration: const Duration(seconds: 7)),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: const SizedBox(),
            ),
          ),

          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: AppTheme.glassColor(context),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: AppTheme.glassBorder(context)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(0, Icons.grid_view_rounded, 'Home'),
                        _buildNavItem(1, Icons.pie_chart_rounded, 'Insights'),
                        _buildNavItem(2, Icons.person_rounded, 'Profile'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.brandPurple : AppTheme.textDimColor(context);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandPurple.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}