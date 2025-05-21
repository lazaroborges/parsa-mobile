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
  final allTransactions =
      await TransactionService.instance.getTransactions().first;
  final uncats = filterUncategorizedTransactions(allTransactions);
  return uncats;
}

/// Returns the count of transactions in the top [limit] income and expense uncategorized groups.
Future<int> countTopUncategorizedTransactions({int limit = 5}) async {
  final groupsMap =
      await getTopUncategorizedGroupsByCousinAndType(limit: limit);
  final topIncome = groupsMap[CategoryType.I] ?? [];
  final topExpense = groupsMap[CategoryType.E] ?? [];
  final allTxs =
      [...topIncome, ...topExpense].expand((g) => g.transactions).toList();
  return allTxs.length;
}

/// Filters a list of transactions, returning only those that are uncategorized.
/// A transaction is uncategorized if its category name is in the uncategorized set
/// and its status is not 'notconsidered'.
List<MoneyTransaction> filterUncategorizedTransactions(
    List<MoneyTransaction> allTransactions) {
  final filtered = allTransactions
      .where((tx) =>
          tx.category?.name != null &&
          UNCATEGORIZED_CATEGORY_NAMES.contains(tx.category!.name) &&
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

/// Groups uncategorized transactions by cousin id and type (income/expense),
/// and returns the top [limit] groups for each type, sorted by absolute total value.
Future<Map<CategoryType, List<TransactionGroupByType>>>
    getTopUncategorizedGroupsByCousinAndType({
  int limit = 10,
}) async {
  final uncats = await getUncategorizedTransactions();
  // Filter out transactions with status notconsidered
  final filtered = uncats
      .where((tx) => tx.status != TransactionStatus.notconsidered)
      .toList();
  // Group by cousin id and type
  final Map<int, List<MoneyTransaction>> byCousin = {};
  for (var tx in filtered) {
    if (tx.cousin != null) {
      byCousin.putIfAbsent(tx.cousin!, () => []).add(tx);
    }
  }
  // For each cousin, split into income and expense groups
  List<TransactionGroupByType> incomeGroups = [];
  List<TransactionGroupByType> expenseGroups = [];
  byCousin.forEach((cousin, txs) {
    final incomeTxs = txs.where((tx) => (tx.value ?? 0) > 0).toList();
    final expenseTxs = txs.where((tx) => (tx.value ?? 0) < 0).toList();
    if (incomeTxs.isNotEmpty) {
      incomeGroups.add(TransactionGroupByType(
        cousin: cousin,
        type: CategoryType.I,
        transactions: incomeTxs,
      ));
    }
    if (expenseTxs.isNotEmpty) {
      expenseGroups.add(TransactionGroupByType(
        cousin: cousin,
        type: CategoryType.E,
        transactions: expenseTxs,
      ));
    }
  });
  incomeGroups.sort((a, b) => b.totalValue.abs().compareTo(a.totalValue.abs()));
  expenseGroups
      .sort((a, b) => b.totalValue.abs().compareTo(a.totalValue.abs()));
  return {
    CategoryType.I: incomeGroups.take(limit).toList(),
    CategoryType.E: expenseGroups.take(limit).toList(),
  };
}

/// Returns the top [limit] groups (income and expense, separated) as a single list, sorted by absolute value.
Future<List<TransactionGroupByType>>
    getTopUncategorizedGroupsByCousinTotalAmountSeparated({
  int limit = 10,
}) async {
  final groupsMap =
      await getTopUncategorizedGroupsByCousinAndType(limit: limit);
  final allGroups = <TransactionGroupByType>[];
  allGroups.addAll(groupsMap[CategoryType.I] ?? []);
  allGroups.addAll(groupsMap[CategoryType.E] ?? []);
  allGroups.sort((a, b) => b.totalValue.abs().compareTo(a.totalValue.abs()));
  return allGroups.take(limit).toList();
}

/// For a given cousin id, get all uncategorized transactions of a specific type (income or expense).
Future<List<MoneyTransaction>> getUncategorizedTransactionsForCousinAndType(
    int cousin, CategoryType type) async {
  final uncats = await getUncategorizedTransactions();
  final filtered = uncats
      .where((tx) =>
          tx.status != TransactionStatus.notconsidered &&
          tx.cousin == cousin &&
          ((type == CategoryType.I && (tx.value ?? 0) > 0) ||
              (type == CategoryType.E && (tx.value ?? 0) < 0)))
      .toList();
  return filtered;
}

/// Groups uncategorized transactions by cousin id and returns the top [limit] groups
/// ranked by the absolute total amount (income or expense combined).
Future<List<TransactionGroupByType>>
    getTopUncategorizedGroupsByCousinTotalAmount({
  int limit = 10,
}) async {
  final uncats = await getUncategorizedTransactions();
  // Filter out transactions with status notconsidered
  final filtered = uncats
      .where((tx) => tx.status != TransactionStatus.notconsidered)
      .toList();
  // Group by cousin id
  final Map<int, List<MoneyTransaction>> byCousin = {};
  for (var tx in filtered) {
    if (tx.cousin != null) {
      byCousin.putIfAbsent(tx.cousin!, () => []).add(tx);
    }
  }
  // Create groups and sort by absolute total value
  final groups = byCousin.entries.map((e) {
    final txs = e.value;
    final total = txs.fold(0.0, (sum, tx) => sum + (tx.value ?? 0));
    return TransactionGroupByType(
      cousin: e.key,
      // Type is not relevant here, but we can infer it if needed
      type: total >= 0 ? CategoryType.I : CategoryType.E,
      transactions: txs,
    );
  }).toList()
    ..sort((a, b) => b.totalValue.abs().compareTo(a.totalValue.abs()));
  return groups.take(limit).toList();
}

/// Returns a list of summaries for all uncategorized (NA) transaction groups.
/// Each summary contains:
///   cousin_id, type (income/expense), TotalAmount (abs), totalTransactions
Future<List<Map<String, dynamic>>> getUncategorizedGroupSummaries() async {
  final groups = await getTopUncategorizedGroupsByCousinTotalAmountSeparated();
  return groups
      .map((g) => {
            'cousin_id': g.cousin,
            'type': g.type == CategoryType.I ? 'income' : 'expense',
            'TotalAmount': g.totalValue.abs(),
            'totalTransactions': g.transactions.length,
          })
      .toList();
}
