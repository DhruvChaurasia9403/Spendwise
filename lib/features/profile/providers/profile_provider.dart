import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../transactions/repositories/transaction_repository.dart';
import '../models/user_profile.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<UserProfile?> build() async {
    final db = ref.read(databaseServiceProvider).db;
    return await db.userProfiles.get(1); // Try to fetch the single user profile
  }

  Future<void> saveProfile({
    required String name,
    required double income,
    required bool isYearly,
    String avatar = '👤',
  }) async {
    final db = ref.read(databaseServiceProvider).db;

    final profile = UserProfile()
      ..id = 1
      ..name = name
      ..avatar = avatar
      ..targetIncome = income
      ..isYearlyIncome = isYearly
      ..appStartDate = state.valueOrNull?.appStartDate ?? DateTime.now();

    await db.writeTxn(() async {
      await db.userProfiles.put(profile);
    });

    state = AsyncValue.data(profile);
  }


}