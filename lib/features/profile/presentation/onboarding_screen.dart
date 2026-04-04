import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_text_field.dart';
import '../providers/profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();

  bool _isYearly = false;
  String _selectedAvatar = '👤';

  final List<String> availableAvatars = const [
    '👤',
    '🚀',
    '🦊',
    '🧠',
    '💼',
    '🌈',
    '🔥',
    '👑'
  ];

  void _completeSetup() {
    final name = _nameController.text.trim();
    final incomeText = _incomeController.text.trim();

    if (name.isEmpty || incomeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    final income = double.tryParse(incomeText);

    if (income == null || income <= 0) return;

    ref.read(profileNotifierProvider.notifier).saveProfile(
      name: name,
      income: income,
      isYearly: _isYearly,
      avatar: _selectedAvatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.textColor(context);
    final textDimColor = AppTheme.textDimColor(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Spendwise',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s personalize your experience.',
                  style: TextStyle(
                    fontSize: 16,
                    color: textDimColor,
                  ),
                ),
                const SizedBox(height: 40),
                GlassTextField(
                  hintText: 'What is your name?',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  hintText: 'Your Base Income (₹)',
                  controller: _incomeController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.currency_rupee,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.glassColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.glassBorder(context),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Income Frequency',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Monthly',
                            style: TextStyle(
                              color: !_isYearly
                                  ? textColor
                                  : textDimColor,
                            ),
                          ),
                          Switch(
                            value: _isYearly,
                            activeColor: AppTheme.brandPurple,
                            onChanged: (val) =>
                                setState(() => _isYearly = val),
                          ),
                          Text(
                            'Yearly',
                            style: TextStyle(
                              color: _isYearly
                                  ? textColor
                                  : textDimColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Choose Your Avatar',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: availableAvatars.map((avatar) {
                    final isSelected = _selectedAvatar == avatar;

                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedAvatar = avatar),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.brandPurple.withAlpha(
                            ((isDark ? 0.4 : 0.2) * 255)
                                .toInt(),
                          )
                              : AppTheme.glassColor(context),
                          borderRadius:
                          BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.brandPurple
                                : AppTheme.glassBorder(context),
                          ),
                        ),
                        child: Text(
                          avatar,
                          style:
                          const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandPurple,
                      elevation: 8,
                      shadowColor: AppTheme.brandPurple
                          .withAlpha((0.4 * 255).toInt()),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _completeSetup,
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}