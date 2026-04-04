import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/transactions/models/transaction.dart';

class DatabaseService {
  late Isar db;


  Future<void> initDb() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      db = await Isar.open(
        [TransactionSchema],
        directory: dir.path,
        inspector: true,
      );
    } else {
      db = Isar.getInstance()!;
    }
  }
}