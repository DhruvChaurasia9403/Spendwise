import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spendwise/core/routing/main_layout.dart';

import 'core/database/database.dart';
import 'core/theme/theme_provider.dart';
import 'features/profile/presentation/onboarding_screen.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/transactions/repositories/transaction_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseService();
  await dbService.initDb();

  runApp(
    ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(dbService),
      ],
      child: const SpendwiseApp(),
    ),
  );
}

class SpendwiseApp extends ConsumerWidget {
  const SpendwiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    return MaterialApp(
      title: 'Spendwise',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: profileAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
        data: (profile) {
          if (profile == null) {
            return const OnboardingScreen();
          }
          return const MainLayout();
        },
      ),
    );
  }
}