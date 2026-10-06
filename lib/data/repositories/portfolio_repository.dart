import 'package:pecule/data/local/paper_transaction_dao.dart';
import 'package:pecule/domain/models/paper_transaction.dart';

class PortfolioRepository {
  PortfolioRepository({required this._transactions});

  final PaperTransactionDao _transactions;

  Future<List<PaperTransaction>> getTransactions() => _transactions.findAll();

  Future<void> addTransaction(PaperTransaction transaction) =>
      _transactions.insert(transaction);

  /// « Réinitialiser le portefeuille » : efface tous les achats fictifs.
  Future<void> reset() => _transactions.deleteAll();
}
