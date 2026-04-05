import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_month_provider.g.dart';

@riverpod
class SelectedMonth extends _$SelectedMonth {
  @override
  DateTime build() {
    // Default to the current month when the app opens
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime date) {
    state = DateTime(date.year, date.month);
  }
}