import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/models/category/category.dart';

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

/// Fetches all transactions and returns only those considered 'uncategorized'.
/// A transaction is uncategorized if its category name is in the uncategorized set
/// and its status is not 'notconsidered'.
Future<List<MoneyTransaction>> getUncategorizedTransactions() async {
  print('[PERF] getUncategorizedTransactions: START');
  final startTime = DateTime.now();

  final allTransactions =
      await TransactionService.instance.getTransactions().first;
  final fetchTime = DateTime.now();
  print(
      '[PERF] Fetched all transactions: ${fetchTime.difference(startTime).inMilliseconds}ms (${allTransactions.length} transactions)');

  final uncats = filterUncategorizedTransactions(allTransactions);
  final filterTime = DateTime.now();
  print(
      '[PERF] Filtered uncategorized: ${filterTime.difference(fetchTime).inMilliseconds}ms (${uncats.length} uncategorized)');
  print(
      '[PERF] getUncategorizedTransactions: TOTAL ${filterTime.difference(startTime).inMilliseconds}ms');

  return uncats;
}

/// Filters a list of transactions, returning only those that are uncategorized.
/// A transaction is uncategorized if its category name is in the uncategorized set
/// and its status is not 'notconsidered'.
/// Filters a list of transactions, returning only those that are uncategorized.
/// A transaction is uncategorized if its category name is in the uncategorized set
/// and its status is not 'notconsidered'.
List<MoneyTransaction> filterUncategorizedTransactions(
    List<MoneyTransaction> allTransactions) {
  // TEMPORARY: Return all transactions (ignore category filter)
  final filtered = allTransactions
      .where((tx) =>
          tx.status != TransactionStatus.notconsidered)
      .toList();
  return filtered;
}

/// Represents a group of transactions sharing the same cousin id and classified as income or expense.
/// The type is set by the grouping logic, not by the category.
class TransactionGroupByType {
  final int cousin;
  final CategoryType type; // I for income, E for expense
  final List<MoneyTransaction> transactions;
  TransactionGroupByType({
    required this.cousin,
    required this.type,
    required this.transactions,
  });

  /// Sum of all transaction values in this group.
  /// For income, sum only positive values. For expense, sum only negative values (as positive).
  double get totalValue {
    if (type == CategoryType.I) {
      // Sum only positive values
      return transactions.fold(
          0.0, (sum, tx) => sum + ((tx.value ?? 0) > 0 ? tx.value! : 0));
    } else {
      // Sum only negative values, as positive
      return transactions.fold(
          0.0, (sum, tx) => sum + ((tx.value ?? 0) < 0 ? -tx.value! : 0));
    }
  }

  /// Number of transactions in this group.
  int get count => transactions.length;
}

/// OPTIMIZED: Gets the top 10 uncategorized groups efficiently in a single pass
/// This avoids the N+1 query problem by fetching all data once and grouping it
Future<List<TransactionGroupByType>>
    getTop10UncategorizedGroupsOptimized() async {
  print('[PERF] getTop10UncategorizedGroupsOptimized: START');
  final startTime = DateTime.now();

  // Fetch all uncategorized transactions once
  final uncats = await getUncategorizedTransactions();
  final fetchTime = DateTime.now();
  print(
      '[PERF] OPTIMIZED: Fetched uncategorized transactions: ${fetchTime.difference(startTime).inMilliseconds}ms (${uncats.length} transactions)');

  // Filter out transactions with status notconsidered and group by cousin
  final filtered = uncats
      .where((tx) =>
          tx.status != TransactionStatus.notconsidered && tx.cousin != null)
      .toList();

  final Map<int, List<MoneyTransaction>> byCousin = {};
  for (var tx in filtered) {
    byCousin.putIfAbsent(tx.cousin!, () => []).add(tx);
  }

  // Create all groups (income and expense separately)
  List<TransactionGroupByType> allGroups = [];
  byCousin.forEach((cousin, txs) {
    final incomeTxs = txs.where((tx) => (tx.value ?? 0) > 0).toList();
    final expenseTxs = txs.where((tx) => (tx.value ?? 0) < 0).toList();

    if (incomeTxs.isNotEmpty) {
      allGroups.add(TransactionGroupByType(
        cousin: cousin,
        type: CategoryType.I,
        transactions: incomeTxs,
      ));
    }
    if (expenseTxs.isNotEmpty) {
      allGroups.add(TransactionGroupByType(
        cousin: cousin,
        type: CategoryType.E,
        transactions: expenseTxs,
      ));
    }
  });

  // Sort by total value and take top 10
  allGroups.sort((a, b) => b.totalValue.abs().compareTo(a.totalValue.abs()));
  final result = allGroups.take(50).toList();

  final endTime = DateTime.now();
  print(
      '[PERF] OPTIMIZED: Total time: ${endTime.difference(startTime).inMilliseconds}ms (${result.length} groups)');

  return result;
}

/// OPTIMIZED: Gets summaries efficiently using the optimized approach
Future<List<Map<String, dynamic>>> getUncategorizedGroupSummaries() async {
  print('[PERF] getUncategorizedGroupSummaries (OPTIMIZED): START');
  final startTime = DateTime.now();

  final groups = await getTop10UncategorizedGroupsOptimized();
  final result = groups
      .map((g) => {
            'cousin_id': g.cousin,
            'type': g.type == CategoryType.I ? 'income' : 'expense',
            'TotalAmount': g.totalValue.abs(),
            'totalTransactions': g.transactions.length,
          })
      .toList();

  final endTime = DateTime.now();
  print(
      '[PERF] getUncategorizedGroupSummaries (OPTIMIZED): ${endTime.difference(startTime).inMilliseconds}ms');
  return result;
}

/// Returns the count of transactions in the top uncategorized groups (optimized)
Future<int> countTopUncategorizedTransactions({int limit = 10}) async {
  print('[PERF] countTopUncategorizedTransactions (OPTIMIZED): START');
  final startTime = DateTime.now();

  final groups = await getTop10UncategorizedGroupsOptimized();
  final count = groups.fold<int>(0, (sum, g) => sum + g.count);

  final endTime = DateTime.now();
  print(
      '[PERF] countTopUncategorizedTransactions (OPTIMIZED): ${endTime.difference(startTime).inMilliseconds}ms (count: $count)');
  return count;
}
