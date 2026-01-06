import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class HiveBoxes {
  static Box<TransactionModel> transactions() =>
      Hive.box<TransactionModel>('transactions');
}
