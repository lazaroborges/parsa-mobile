import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';

// Map of uncategorized pluggy category codes to display names
const Map<String, String> NA_CATEGORIES = {
  '04000000': 'Transferência Bancária',
  '04010000': 'Transferência Bancária',
  '04020000': 'Transferência Bancária',
  '04030000': 'Transferência Bancária',
  '05000000': 'Transferência Bancária',
  '05010000': 'Transferência Bancária',
  '05020000': 'Transferência Bancária',
  '05030000': 'Transferência Bancária',
  '05040000': 'Transferência Bancária',
  '05050000': 'Transferência Bancária',
  '05060000': 'Transferência Bancária',
  '05070000': 'Transferência Bancária',
  '05080000': 'Transferência Bancária',
  '05090000': 'Transferência Bancária',
  '05090001': 'Transferência Bancária',
  '05090002': 'Transferência Bancária',
  '05090003': 'Transferência Bancária',
  '05090004': 'Transferência Bancária',
  '05090005': 'Transferência Bancária',
  '05100000': 'Pagamento Fatura do Cartão',
  '12020000': 'Outros',
  '12030000': 'Outros',
  '13000000': 'Outros',
  '99999998': 'Despesa Não Classificada',
  '99999999': 'Outros',
};

// Set of uncategorized category display names
final Set<String> UNCATEGORIZED_CATEGORY_NAMES = NA_CATEGORIES.values.toSet();

Future<List<MoneyTransaction>> getUncategorizedTransactions() async {
  final allTransactions =
      await TransactionService.instance.getTransactions().first;
  return filterUncategorizedTransactions(allTransactions);
}

/// Returns a Future<int> with the count of uncategorized transactions.
Future<int> countUncategorizedTransactions() async {
  final uncategorizedTransactions = await getUncategorizedTransactions();
  return uncategorizedTransactions.length;
}

/// Filters transactions whose category name matches one of the uncategorized names and excludes notconsidered status
List<MoneyTransaction> filterUncategorizedTransactions(
    List<MoneyTransaction> allTransactions) {
  return allTransactions
      .where((tx) =>
          tx.category?.name != null &&
          UNCATEGORIZED_CATEGORY_NAMES.contains(tx.category!.name) &&
          tx.status != TransactionStatus.notconsidered)
      .toList();
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

// New helper: group uncategorized transactions by cousin
Future<List<List<MoneyTransaction>>> getTopUncategorizedByCousin(
    {int limit = 10}) async {
  final allTxs = await getUncategorizedTransactions();

  // Group by non-null cousin id
  final Map<int, List<MoneyTransaction>> byCousin = {};
  for (var tx in allTxs) {
    if (tx.cousin != null) {
      byCousin.putIfAbsent(tx.cousin!, () => []).add(tx);
    }
  }

  // Sort groups by size descending and take top [limit]
  final entries = byCousin.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));
  final topEntries = entries.take(limit).toList();
  print(
      'Taking top ${topEntries.length} cousin IDs: ${topEntries.map((e) => e.key).join(', ')}');

  // Return only the transaction lists
  return topEntries.map((e) => e.value).toList();
}

// New helper: flatten the top cousin groups into a single list
Future<List<MoneyTransaction>> getTopUncategorizedFlatByCousin(
    {int limit = 10}) async {
  final groups = await getTopUncategorizedByCousin(limit: limit);
  return groups.expand((g) => g).toList();
}

/// Represents a group of transactions sharing the same cousin id.
class TransactionGroup {
  final int cousin;
  final List<MoneyTransaction> transactions;
  TransactionGroup({required this.cousin, required this.transactions});

  /// Sum of all transaction values in this group.
  double get totalValue =>
      transactions.fold(0.0, (sum, tx) => sum + (tx.value ?? 0));

  /// Number of transactions in this group.
  int get count => transactions.length;
}

/// Fetches uncategorized transactions, groups them by cousin id,
/// sorts by total value descending, and returns the top [limit] groups.
Future<List<TransactionGroup>> getTopUncategorizedGroups(
    {int limit = 10}) async {
  final uncats = await getUncategorizedTransactions();
  final Map<int, List<MoneyTransaction>> byCousin = {};
  for (var tx in uncats) {
    if (tx.cousin != null) {
      byCousin.putIfAbsent(tx.cousin!, () => []).add(tx);
    }
  }
  final groups = byCousin.entries
      .map((e) => TransactionGroup(cousin: e.key, transactions: e.value))
      .toList()
    ..sort((a, b) => b.totalValue.compareTo(a.totalValue));
  return groups.take(limit).toList();
}
