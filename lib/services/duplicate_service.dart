import '../models/transaction_model.dart';
class DuplicateService {
  static String fingerprint(TransactionModel tx) {
    return '${tx.date.toIso8601String().substring(0, 10)}'
           '_${tx.amount}'
           '_${tx.title.toLowerCase()}';
  }
}
