import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';

part 'transaction_provider.g.dart';

@riverpod
class TransactionNotifier extends _$TransactionNotifier {
  @override
  Future<List<Transaction>> build() async {
    return _fetchTransactions();
  }

  Future<List<Transaction>> _fetchTransactions() async {
    final repository = ref.read(transactionRepositoryProvider.notifier);
    return await repository.getAllTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionRepositoryProvider.notifier);
      await repository.addTransaction(transaction);
      return _fetchTransactions();
    });
  }

  Future<void> deleteTransaction(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionRepositoryProvider.notifier);
      await repository.deleteTransaction(id);
      return _fetchTransactions();
    });
  }
}