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
  final groupsMap = await getTopUncategorizedGroupsSplitByType(limit: limit);
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
  final CategoryType type;
  final List<MoneyTransaction> transactions;
  TransactionGroupByType({
    required this.cousin,
    required this.type,
    required this.transactions,
  });

  /// Sum of all transaction values in this group.
  double get totalValue =>
      transactions.fold(0.0, (sum, tx) => sum + (tx.value ?? 0));

  /// Number of transactions in this group.
  int get count => transactions.length;
}

/// Groups uncategorized transactions by cousin id, and classifies each group as income or expense
/// based on the sign of the transaction values. Returns the top [limit] groups by absolute value.
Future<List<TransactionGroupByType>> getTopUncategorizedGroupsByType(
    {int limit = 10}) async {
  final uncats = await getUncategorizedTransactions();
  // Exclude transactions with status notconsidered
  final filtered = uncats
      .where((tx) => tx.status != TransactionStatus.notconsidered)
      .toList();
  final Map<int, List<MoneyTransaction>> byCousin = {};
  for (var tx in filtered) {
    if (tx.cousin != null) {
      byCousin.putIfAbsent(tx.cousin!, () => []).add(tx);
    }
  }
  final groups = byCousin.entries.map((e) {
    final txs = e.value;
    final sum = txs.fold(0.0, (s, tx) => s + (tx.value ?? 0));
    final type = sum >= 0 ? CategoryType.I : CategoryType.E;
    return TransactionGroupByType(
      cousin: e.key,
      type: type,
      transactions: txs,
    );
  }).toList()
    ..sort((a, b) => b.totalValue.abs().compareTo(a.totalValue.abs()));
  return groups.take(limit).toList();
}

/// Returns a map with the top [limit] expense and income uncategorized groups by amount.
/// This function splits all uncategorized transactions into income (value > 0) and expense (value < 0),
/// groups each by cousin id, and returns the top [limit] of each type.
Future<Map<CategoryType, List<TransactionGroupByType>>>
    getTopUncategorizedGroupsSplitByType({int limit = 5}) async {
  final uncats = await getUncategorizedTransactions();
  // Split into income and expense transactions
  final incomeTxs = uncats.where((tx) => (tx.value ?? 0) > 0).toList();
  final expenseTxs = uncats.where((tx) => (tx.value ?? 0) < 0).toList();

  // Group each by cousin
  Map<int, List<MoneyTransaction>> groupByCousin(List<MoneyTransaction> txs) {
    final map = <int, List<MoneyTransaction>>{};
    for (var tx in txs) {
      if (tx.cousin != null) {
        map.putIfAbsent(tx.cousin!, () => []).add(tx);
      }
    }
    return map;
  }

  final incomeGroupsMap = groupByCousin(incomeTxs);
  final expenseGroupsMap = groupByCousin(expenseTxs);

  final incomeGroups = incomeGroupsMap.entries
      .map((e) => TransactionGroupByType(
            cousin: e.key,
            type: CategoryType.I,
            transactions: e.value,
          ))
      .toList()
    ..sort((a, b) => b.totalValue.abs().compareTo(a.totalValue.abs()));

  final expenseGroups = expenseGroupsMap.entries
      .map((e) => TransactionGroupByType(
            cousin: e.key,
            type: CategoryType.E,
            transactions: e.value,
          ))
      .toList()
    ..sort((a, b) => b.totalValue.abs().compareTo(a.totalValue.abs()));

  print('[DEBUG] getTopUncategorizedGroupsSplitByType:');
  print(
      '  Top 5 expense: ${expenseGroups.take(limit).map((g) => g.cousin).toList()}');
  print(
      '  Top 5 income: ${incomeGroups.take(limit).map((g) => g.cousin).toList()}');

  return {
    CategoryType.E: expenseGroups.take(limit).toList(),
    CategoryType.I: incomeGroups.take(limit).toList(),
  };
}
