import 'package:drift/drift.dart';
import 'package:parsa/core/api/post_methods/post_user_budget.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/models/budget/budget.dart';

class BudgetServive {
  final AppDB db;

  BudgetServive._(this.db);
  static final BudgetServive instance = BudgetServive._(AppDB.instance);

  Future<bool> insertBudget(Budget budget, {bool skipServerSync = false}) {
    return db.transaction(() async {
      await db.into(db.budgets).insert(BudgetInDB(
          id: budget.id,
          name: budget.name,
          limitAmount: budget.limitAmount,
          intervalPeriod: budget.intervalPeriod,
          startDate: budget.startDate,
          endDate: budget.endDate));

      if (budget.tags != null) {
        for (final tag in budget.tags!) {
          await db.into(db.budgetTag).insert(BudgetTagData(budgetID: budget.id, tagID: tag));
        }
      }

      if (budget.categories != null) {
        for (final category in budget.categories!) {
          await db.into(db.budgetCategory).insert(
              BudgetCategoryData(budgetID: budget.id, categoryID: category));
        }
      }

      if (budget.accounts != null) {
        for (final account in budget.accounts!) {
          await db.into(db.budgetAccount).insert(
              BudgetAccountData(budgetID: budget.id, accountID: account));
        }
      }
      
      // Post budget to server only if skipServerSync is false
      if (!skipServerSync) {
        try {
          await PostUserBudget.postBudget(budget: budget);
        } catch (e) {
          print('Error posting budget to server: $e');
          // Continue even if server sync fails
          // Local data is already saved
        }
      }

      return true;
    });
  }

  Future<bool> deleteBudget(String id, {bool skipServerSync = false}) {
    return db.transaction(() async {
      // Delete budget tags if they exist
      await (db.delete(db.budgetTag)
            ..where((tbl) => tbl.budgetID.isValue(id)))
          .go();
          
      // Delete budget accounts
      await (db.delete(db.budgetAccount)
            ..where((tbl) => tbl.budgetID.isValue(id)))
          .go();

      // Delete budget categories
      await (db.delete(db.budgetCategory)
            ..where((tbl) => tbl.budgetID.isValue(id)))
          .go();

      // Delete the budget itself
      await (db.delete(db.budgets)..where((tbl) => tbl.id.isValue(id))).go();

      // Delete from server if skipServerSync is false
      if (!skipServerSync) {
        try {
          await PostUserBudget.deleteBudget(budgetId: id);
        } catch (e) {
          print('Error deleting budget from server: $e');
          // Continue even if server sync fails
          // Local data is already deleted
        }
      }

      return true;
    });
  }

  Future<bool> updateBudget(Budget budget, {bool skipServerSync = false}) {
    return db.transaction(() async {
      await deleteBudget(budget.id, skipServerSync: skipServerSync);
      await insertBudget(budget, skipServerSync: skipServerSync);
      return true;
    });
  }

  Stream<List<Budget>> getBudgets({
    Expression<bool> Function(Budgets)? predicate,
    OrderBy Function(Budgets)? orderBy,
    int? limit,
    int? offset,
  }) {
    return db
        .getBudgetsWithFullData(
          predicate: predicate,
          orderBy: orderBy,
          limit: (b) => Limit(limit ?? -1, offset),
        )
        .watch();
  }

  Stream<Budget?> getBudgetById(String id) {
    return getBudgets(predicate: (p0) => p0.id.equals(id), limit: 1)
        .map((res) => res.firstOrNull);
  }
}
