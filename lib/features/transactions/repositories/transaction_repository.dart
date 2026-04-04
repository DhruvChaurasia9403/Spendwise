import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database.dart';
import '../models/transaction.dart';
part 'transaction_repository.g.dart';
@riverpod
DatabaseService databaseService(DatabaseServiceRef ref) {
  return DatabaseService();
}

@riverpod
class TransactionRepository extends _$TransactionRepository {
  @override
  FutureOr<TransactionRepository> build() async {
    return this;
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = ref.read(databaseServiceProvider).db;
    return await db.transactions.where().sortByDateDesc().findAll();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final db = ref.read(databaseServiceProvider).db;
    await db.writeTxn(() async {
      await db.transactions.put(transaction);
    });
  }

  Future<void> deleteTransaction(int id) async {
    final db = ref.read(databaseServiceProvider).db;
    await db.writeTxn(() async {
      await db.transactions.delete(id);
    });
  }
}