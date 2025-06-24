import 'package:drift/drift.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/models/category/category.dart';

/// Represents a group of transactions sharing the same cousin id and classified as income or expense.
/// This object comes fully populated with period and lifetime stats, ready for display.
class TransactionGroupByType {
  final int cousin;
  final CategoryType type; // I for income, E for expense
  final List<MoneyTransaction> transactions;
  final int lifetimeTransactionCount;
  final double lifetimeTotalAmount;

  TransactionGroupByType({
    required this.cousin,
    required this.type,
    required this.transactions,
    required this.lifetimeTransactionCount,
    required this.lifetimeTotalAmount,
  });

  /// Sum of all transaction values in this group for the period.
  double get totalValueInPeriod {
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

  /// Number of transactions in this group for the period.
  int get countInPeriod => transactions.length;
}

/// Helper class to hold the aggregated data from the SQL query.
class CousinGroupSummary {
  final int cousin;
  final CategoryType type;
  final int transactionsInPeriod;
  final int transactionsInTotal;
  final double totalAmount;

  CousinGroupSummary({
    required this.cousin,
    required this.type,
    required this.transactionsInPeriod,
    required this.transactionsInTotal,
    required this.totalAmount,
  });
}

/// Fetches and processes cousin groups for a given period using an efficient, single SQL query for aggregation.
Future<List<TransactionGroupByType>> getCousinGroupsForPeriod(
    DateTime start, DateTime end) async {
  print('[PERF] getCousinGroupsForPeriod (Optimized): START');
  final startTime = DateTime.now();
  final db = AppDB.instance;

  // 1. Get aggregated summaries with a single, powerful SQL query.
  const summaryQuery = """
    SELECT
      t.cousin,
      CASE WHEN t.value > 0 THEN 'I' ELSE 'E' END as type,
      COUNT(t.id) as transactionsInTotal,
      SUM(ABS(t.value)) as totalAmount,
      SUM(CASE WHEN t.date >= ? AND t.date <= ? THEN 1 ELSE 0 END) as transactionsInPeriod
    FROM transactions t
    WHERE t.cousin IS NOT NULL AND t.status != 'notconsidered'
    GROUP BY t.cousin, CASE WHEN t.value > 0 THEN 'I' ELSE 'E' END
    HAVING transactionsInPeriod > 0 AND transactionsInTotal > 1
  """;

  final summaryResult = await db.customSelect(summaryQuery,
      variables: [Variable.withDateTime(start), Variable.withDateTime(end)],
      readsFrom: {db.transactions}).get();

  final summaries = summaryResult.map((row) {
    return CousinGroupSummary(
      cousin: row.read<int>('cousin'),
      type: row.read<String>('type') == 'I' ? CategoryType.I : CategoryType.E,
      transactionsInTotal: row.read<int>('transactionsInTotal'),
      totalAmount: row.read<double>('totalAmount'),
      transactionsInPeriod: row.read<int>('transactionsInPeriod'),
    );
  }).toList();

  if (summaries.isEmpty) {
    print(
        '[PERF] getCousinGroupsForPeriod (Optimized): END. No groups found. Took ${DateTime.now().difference(startTime).inMilliseconds}ms.');
    return [];
  }

  // 2. Get the full transaction objects for the cousins found in the period.
  final cousinIds = summaries.map((s) => s.cousin).toSet();
  final allTransactionsForPeriod =
      (await TransactionService.instance.getTransactions().first)
          .where((tx) =>
              tx.date != null &&
              !tx.date!.isBefore(start) &&
              !tx.date!.isAfter(end) &&
              cousinIds.contains(tx.cousin))
          .toList();

  // 3. Combine summaries and transaction objects into the final data structure.
  final groups = summaries.map((summary) {
    final txs = allTransactionsForPeriod
        .where((tx) =>
            tx.cousin == summary.cousin &&
            ((summary.type == CategoryType.I && (tx.value ?? 0) > 0) ||
                (summary.type == CategoryType.E && (tx.value ?? 0) < 0)))
        .toList();

    return TransactionGroupByType(
      cousin: summary.cousin,
      type: summary.type,
      transactions: txs,
      lifetimeTransactionCount: summary.transactionsInTotal,
      lifetimeTotalAmount: summary.totalAmount,
    );
  }).toList();

  // Sort groups by total lifetime value for relevance.
  groups.sort((a, b) => b.lifetimeTotalAmount.compareTo(a.lifetimeTotalAmount));

  print(
      '[PERF] getCousinGroupsForPeriod (Optimized): END. Took ${DateTime.now().difference(startTime).inMilliseconds}ms for ${groups.length} groups.');
  return groups;
}

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
  final filtered = allTransactions
      .where((tx) => tx.status != TransactionStatus.notconsidered)
      .toList();
  return filtered;
}
