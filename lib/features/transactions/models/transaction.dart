import 'package:isar/isar.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late double amount;

  @Enumerated(EnumType.name)
  late TransactionType type;

  late String category;

  @Index()
  late DateTime date;

  String? notes;
  bool get isExpense => type == TransactionType.expense;
}

enum TransactionType {
  income,
  expense,
}