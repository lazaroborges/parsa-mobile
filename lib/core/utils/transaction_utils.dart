import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';

const List<String> UNCATEGORIZED_CATEGORIES = [
  "04000000",
  "04010000",
  "04020000",
  "04030000",
  "05000000",
  "05010000",
  "05020000",
  "05030000",
  "05040000",
  "05050000",
  "05060000",
  "05070000",
  "05080000",
  "05090000",
  "05090001",
  "05090002",
  "05090003",
  "05090004",
  "05090005",
  "99999998",
  "99999999",
  "21000000"
];

/// Returns a list of uncategorized transactions from all transactions.
List<MoneyTransaction> getUncategorizedTransactions(
    List<MoneyTransaction> allTransactions) {
  return allTransactions
      .where((tx) => UNCATEGORIZED_CATEGORIES.contains(tx.category?.id))
      .toList();
}

/// Returns the count of uncategorized transactions from all transactions.
int countUncategorizedTransactions(List<MoneyTransaction> allTransactions) {
  return getUncategorizedTransactions(allTransactions).length;
}

/// Returns a Future<List<MoneyTransaction>> for a given category name (e.g., 'Lazer').
Future<List<MoneyTransaction>> getTransactionsByCategoryName(
    String categoryName) async {
  final category =
      await CategoryService.instance.getCategoryByName(categoryName).first;
  if (category == null) return [];
  return await TransactionService.instance
      .getTransactions(filters: TransactionFilters(categories: [category.id]))
      .first;
}

/// Returns a Future<int> for the count of transactions for a given category name.
Future<int> countTransactionsByCategoryName(String categoryName) async {
  final txs = await getTransactionsByCategoryName(categoryName);
  return txs.length;
}
