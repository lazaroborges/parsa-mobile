import 'package:drift/drift.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/models/category/category.dart';

/// Helper class to hold the aggregated data from the SQL query.
class CousinGroupSummary {
  final int cousin;
  final CategoryType type;
  final int transactionCount;
  final double totalAmount;

  CousinGroupSummary({
    required this.cousin,
    required this.type,
    required this.transactionCount,
    required this.totalAmount,
  });

  @override
  String toString() {
    return 'CousinGroupSummary(cousin: $cousin, type: $type, transactionCount: $transactionCount, totalAmount: $totalAmount)';
  }
}

/// Fetches and processes cousin group summaries for a given period using an efficient, single SQL query for aggregation.
/// Returns only the summary (cousin, type, transactionCount, totalAmount),
/// separated into E (expense) and I (income), excluding 'notconsidered' and groups with only one transaction.
Future<List<CousinGroupSummary>> getCousinGroupSummariesForPeriod(
    DateTime start, DateTime end) async {
  final db = AppDB.instance;

  // Adjust for the 3-hour timezone difference in the DB
  final dbQueryStart = start.add(const Duration(hours: 3));
  final dbQueryEnd = end.add(const Duration(hours: 3));

  final stopwatch = Stopwatch()..start();

  // Get aggregated summaries with a single, powerful SQL query.
  const summaryQuery = """
    SELECT
      t.cousin,
      CASE WHEN t.value > 0 THEN 'I' ELSE 'E' END as type,
      COUNT(t.id) as transactionCount,
      SUM(ABS(t.value)) as totalAmount
    FROM transactions t
    WHERE t.cousin IS NOT NULL 
      AND t.status != 'notconsidered'
      AND t.date >= ? AND t.date <= ?
    GROUP BY t.cousin, CASE WHEN t.value > 0 THEN 'I' ELSE 'E' END
  """;

  final summaryResult = await db.customSelect(summaryQuery, variables: [
    Variable.withDateTime(dbQueryStart),
    Variable.withDateTime(dbQueryEnd)
  ], readsFrom: {
    db.transactions
  }).get();

  final summaries = summaryResult.map((row) {
    return CousinGroupSummary(
      cousin: row.read<int>('cousin'),
      type: row.read<String>('type') == 'I' ? CategoryType.I : CategoryType.E,
      transactionCount: row.read<int>('transactionCount'),
      totalAmount: row.read<double>('totalAmount'),
    );
  }).toList();

  stopwatch.stop();
  print(
      'getCousinGroupSummariesForPeriod executed in [32m[1m[4m[3m[7m[5m${stopwatch.elapsedMilliseconds}ms\u001b[0m');

  return summaries;
}
