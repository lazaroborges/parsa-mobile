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
final Set<String> COUSIN_CATEGORY_NAMES = NA_CATEGORIES.values.toSet();

/// Fetches all transactions and returns only those considered 'cousin'.
/// A transaction is cousin if its category name is in the cousin set
/// and its status is not 'notconsidered'.
Future<List<MoneyTransaction>> getCousinTransactions() async {
  final allTransactions =
      await TransactionService.instance.getTransactions().first;
  final cousins = filterCousinTransactions(allTransactions);
  return cousins;
}

/// Filters a list of transactions, returning only those that are cousin.
/// A transaction is cousin if its category name is in the cousin set
/// and its status is not 'notconsidered'.
List<MoneyTransaction> filterCousinTransactions(
    List<MoneyTransaction> allTransactions) {
  // TEMPORARY: Return all transactions (ignore category filter)
  final filtered = allTransactions
      .where((tx) => tx.status != TransactionStatus.notconsidered)
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

class CousinGroupResult {
  final List<TransactionGroupByType> groups;
  final int totalTransactions;
  final int totalGroups;
  CousinGroupResult(
      {required this.groups,
      required this.totalTransactions,
      required this.totalGroups});
}

Future<CousinGroupResult> getCousinGroupsForPeriod(
    DateTime start, DateTime end) async {
  // Fetch all transactions only once
  final allTransactions =
      await TransactionService.instance.getTransactions().first;

  // Filter transactions in the period
  final filtered = allTransactions.where((tx) {
    return tx.status != TransactionStatus.notconsidered &&
        tx.cousin != null &&
        tx.date != null &&
        !tx.date!.isBefore(start) &&
        !tx.date!.isAfter(end);
  }).toList();

  final Map<int, List<MoneyTransaction>> byCousin = {};
  for (var tx in filtered) {
    byCousin.putIfAbsent(tx.cousin!, () => []).add(tx);
  }

  List<TransactionGroupByType> allGroups = [];
  for (var entry in byCousin.entries) {
    final cousin = entry.key;
    final txs = entry.value;
    // For each type (income/expense), check period and lifetime count
    final incomeTxsPeriod = txs.where((tx) => (tx.value ?? 0) > 0).toList();
    final expenseTxsPeriod = txs.where((tx) => (tx.value ?? 0) < 0).toList();

    // Use allTransactions for lifetime check
    final incomeTxsLifetime = allTransactions
        .where((tx) =>
            tx.cousin == cousin &&
            tx.status != TransactionStatus.notconsidered &&
            (tx.value ?? 0) > 0)
        .toList();
    final expenseTxsLifetime = allTransactions
        .where((tx) =>
            tx.cousin == cousin &&
            tx.status != TransactionStatus.notconsidered &&
            (tx.value ?? 0) < 0)
        .toList();

    if (incomeTxsLifetime.length > 1 && incomeTxsPeriod.isNotEmpty) {
      allGroups.add(TransactionGroupByType(
        cousin: cousin,
        type: CategoryType.I,
        transactions: incomeTxsPeriod,
      ));
    }
    if (expenseTxsLifetime.length > 1 && expenseTxsPeriod.isNotEmpty) {
      allGroups.add(TransactionGroupByType(
        cousin: cousin,
        type: CategoryType.E,
        transactions: expenseTxsPeriod,
      ));
    }
  }

  // Sort groups by total value in descending order
  allGroups.sort((a, b) => b.totalValue.compareTo(a.totalValue));

  // Only count transactions in valid groups
  final validTransactionIds =
      allGroups.expand((g) => g.transactions.map((tx) => tx.id)).toSet();
  final totalTransactions =
      filtered.where((tx) => validTransactionIds.contains(tx.id)).length;
  final totalGroups = allGroups.length;
  return CousinGroupResult(
      groups: allGroups,
      totalTransactions: totalTransactions,
      totalGroups: totalGroups);
}

/// OPTIMIZED: Gets summaries efficiently using the optimized approach
Future<List<Map<String, dynamic>>> getCousinGroupSummaries(
    DateTime start, DateTime end) async {
  print('[PERF] getCousinGroupSummaries (OPTIMIZED): START');
  final startTime = DateTime.now();

  final groups = await getCousinGroupsForPeriod(start, end);
  final result = groups.groups
      .map((g) => {
            'cousin_id': g.cousin,
            'type': g.type == CategoryType.I ? 'income' : 'expense',
            'TotalAmount': g.totalValue.abs(),
            'totalTransactions': g.transactions.length,
          })
      .toList();

  final endTime = DateTime.now();
  print(
      '[PERF] getCousinGroupSummaries (OPTIMIZED): [32m${endTime.difference(startTime).inMilliseconds}ms[0m');
  return result;
}
