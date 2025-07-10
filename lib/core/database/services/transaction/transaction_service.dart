import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:parsa/core/api/fetch_user_data_server.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/models/tags/tag.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';

import 'package:rxdart/rxdart.dart';
import 'package:parsa/core/api/post_methods/post_user_transaction.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';

import '../../../models/transaction/transaction_type.enum.dart';
import 'dart:convert';

class TransactionQueryStatResult {
  int numberOfRes;
  double valueSum;

  TransactionQueryStatResult(
      {required this.numberOfRes, required this.valueSum});
}

typedef TransactionQueryOrderBy = OrderBy Function(
    Transactions transaction,
    Accounts account,
    Currencies accountCurrency,
    Accounts receivingAccount,
    Currencies receivingAccountCurrency,
    Categories c,
    Categories);

class TransactionChanges {
  final String? description;
  final String? categoryName;
  final TransactionStatus? status;
  final String? notes;
  final List<Tag>? tags;

  TransactionChanges({
    this.description,
    this.categoryName,
    this.status,
    this.notes,
    this.tags,
  });

  bool get hasChanges =>
      description != null ||
      categoryName != null ||
      status != null ||
      notes != null ||
      tags != null;

  Map<String, dynamic> toJson() => {
        if (description != null)
          'description': utf8.decode(utf8.encode(description!)),
        if (categoryName != null)
          'category': utf8.decode(utf8.encode(categoryName!)),
        if (status != null) 'status': status?.name,
        if (notes != null) 'notes': utf8.decode(utf8.encode(notes!)),
        if (tags != null) 'tags': tags?.map((tag) => tag.id).toList(),
      };
}

class TransactionService {
  final AppDB db;

  TransactionService._(this.db);
  static final TransactionService instance =
      TransactionService._(AppDB.instance);

  static Future<bool?> Function(
      int numberOfCousins,
      String triggeringId,
      int cousinValue,
      bool positiveInflow,
      TransactionChanges changes)? onCousinFound;
  Future<int> insertTransaction(TransactionInDB transaction) async {
    final toReturn = await db.into(db.transactions).insert(transaction);
    db.markTablesUpdated([db.accounts]);

    return toReturn;
  }

  Future<int> insertOrUpdateTransaction(TransactionInDB transaction,
      [List<Tag>? tags, int? notMassUpdate]) async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;

      final existing = await (db.select(db.transactions)
            ..where((t) => t.id.equals(transaction.id)))
          .getSingleOrNull();

      // If no tags provided and transaction exists, get existing tags
      List<Tag> tagsToUse = tags ?? [];
      if (tags == null && existing != null) {
        final existingTags = await (db.select(db.transactionTags)
              ..where((t) => t.transactionID.equals(transaction.id)))
            .get();

        // Get full tag objects for each existing tag ID
        tagsToUse = await Future.wait(
          existingTags.map((t) async {
            final tagData = await (db.select(db.tags)
                  ..where((tag) => tag.id.equals(t.tagID)))
                .getSingle();
            return Tag.fromTagInDB(tagData);
          }),
        );
      }

      // Track changes if this is an update
      TransactionChanges? changes;
      if (existing != null) {
        changes = TransactionChanges(
          description:
              existing.title != transaction.title ? transaction.title : null,
          categoryName: await _getCategoryName(existing.categoryID) !=
                  await _getCategoryName(transaction.categoryID)
              ? await _getCategoryName(transaction.categoryID)
              : null,
          status:
              existing.status != transaction.status ? transaction.status : null,
          notes: existing.notes != transaction.notes ? transaction.notes : null,
        );

        // Only compare tags if they were explicitly provided
        if (tags != null) {
          final existingTags = await (db.select(db.transactionTags)
                ..where((t) => t.transactionID.equals(transaction.id)))
              .get();
          final existingTagIds = existingTags.map((e) => e.tagID).toSet();
          final newTagIds = tags.map((e) => e.id).toSet();

          if (!setEquals(existingTagIds, newTagIds)) {
            changes = TransactionChanges(
              description: changes.description,
              categoryName: changes.categoryName,
              status: changes.status,
              notes: changes.notes,
              tags: tags,
            );
          }
        }
      }

      if (existing != null) {
        print('Updating existing transaction: ${transaction.id}');

        bool isPosted = await PostUserTransactionService.postUserTransaction(
            transaction: transaction,
            accessToken: credentials!.accessToken,
            tags: tagsToUse,
            method: 'PUT');

        if (!isPosted) {
          throw Exception('Failed to post transaction to the API.');
        }
      } else {
        print('Inserting new transaction: ${transaction.id}');

        bool isPosted = await PostUserTransactionService.postUserTransaction(
            transaction: transaction,
            accessToken: credentials!.accessToken,
            tags: tagsToUse,
            method: 'POST');

        if (!isPosted) {
          throw Exception('Failed to post transaction to the API.');
        }
      }

      final result = await db.into(db.transactions).insert(
            transaction,
            mode: InsertMode.insertOrReplace,
          );

      bool positiveInflow = transaction.value > 0;

      unawaited(_updateTransactionTags(transaction.id, tagsToUse));

      db.markTablesUpdated([db.accounts]);
      unawaited(fetchUserDataAtServer());

      if (existing != null &&
          transaction.cousin != null &&
          notMassUpdate == null) {
        final cousins = await (db.select(db.transactions)
              ..where((t) =>
                  t.cousin.equals(transaction.cousin!) &
                  t.id.isNotValue(transaction.id)))
            .get();

        if (cousins.isNotEmpty && changes?.hasChanges == true) {
          // Check if dontAskAgain is true for this transaction
          if (transaction.dontAskAgain == true) {
            // Skip the dialog if dontAskAgain is set
            print('Skipping cousin dialog - dontAskAgain is true for transaction ${transaction.id}');
          } else if (onCousinFound != null) {
            final shouldContinue = await onCousinFound!(
              cousins.length,
              transaction.id.toString(),
              transaction.cousin!,
              positiveInflow,
              changes!,
            );

            if (shouldContinue == false) {
              throw Exception('Operation cancelled by user');
            }
          }
        }
      }

      return result;
    } catch (e, stackTrace) {
      print('''
Error during insertOrReplace for transaction:
- Transaction ID: ${transaction.id}
- Transaction details: ${transaction.toString()}
- Error: $e
- Stack trace: 
$stackTrace
''');
      rethrow;
    }
  }

  Future<void> _updateTransactionTags(
      String transactionId, List<Tag> tags) async {
    // Delete existing tags for the transaction
    await (db.delete(db.transactionTags)
          ..where((tbl) => tbl.transactionID.equals(transactionId)))
        .go();

    // Insert new tags
    for (var tag in tags) {
      await db
          .into(db.transactionTags)
          .insert(TransactionTag(transactionID: transactionId, tagID: tag.id));
    }
  }

  Future<int> deleteTransaction(String transactionId) async {
    final transaction = await getTransactionById(transactionId).first;

    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    if (transaction.isOpenFinance) {
      throw Exception(
          'Não é possível deletar transações do Open Finance. Caso você queira desconsiderar uma transação, utilize a opção "Desconsiderada" dentro do card da transação.');
    }

    final auth0Provider = Auth0Provider.instance;
    final credentials = await auth0Provider.credentials;

    // Post the account to the API
    bool isPut = await PostUserTransactionService.deleteUserTransaction(
        transactionId, credentials!.accessToken);

    if (!isPut) {
      throw Exception('Failed to post account to the API.');
    } else {
      unawaited(fetchUserDataAtServer()); // Trul

      return (db.delete(db.transactions)
            ..where((tbl) => tbl.id.equals(transactionId)))
          .go();
    }
  }

  Stream<List<MoneyTransaction>> getTransactionsFromPredicate({
    Expression<bool> Function(Transactions, Accounts, Currencies, Accounts,
            Currencies, Categories, Categories)?
        predicate,
    OrderBy Function(
            Transactions transaction,
            Accounts account,
            Currencies accountCurrency,
            Accounts receivingAccount,
            Currencies receivingAccountCurrency,
            Categories c,
            Categories)?
        orderBy,
    int? limit,
    int? offset,
  }) {
    return db
        .getTransactionsWithFullData(
          predicate: predicate,
          orderBy: orderBy,
          limit: (t, a, accountCurrency, ra, receivingAccountCurrency, c, pc) =>
              Limit(limit ?? -1, offset),
        )
        .watch();
  }

  /// Get transactions from the DB based on some filters.
  ///
  /// By default, the transactions will be returned ordered by date
  Stream<List<MoneyTransaction>> getTransactions({
    TransactionFilters? filters,
    TransactionQueryOrderBy? orderBy,
    int? limit,
    int? offset,
  }) {
    return getTransactionsFromPredicate(
        predicate: filters?.toTransactionExpression(),
        orderBy: orderBy ??
            (p0, p1, p2, p3, p4, p5, p6) => OrderBy(
                [OrderingTerm(expression: p0.date, mode: OrderingMode.desc)]),
        limit: limit,
        offset: offset);
  }

  Stream<TransactionQueryStatResult> countTransactions({
    TransactionFilters predicate = const TransactionFilters(),
    bool convertToPreferredCurrency = true,
    DateTime? exchDate,
  }) {
    if (predicate.transactionTypes == null ||
        predicate.transactionTypes!
            .map((e) => e.index)
            .contains(TransactionType.T.index)) {
      // If we should take into account transfers:
      return Rx.combineLatest([
        // INCOME AND EXPENSES
        db
            .countTransactions(
              predicate: predicate
                  .copyWith(
                    transactionTypes: predicate.transactionTypes
                            ?.whereNot((element) =>
                                element.index == TransactionType.T.index)
                            .toList() ??
                        [TransactionType.I, TransactionType.E],
                  )
                  .toTransactionExpression(),
              date: (exchDate ?? DateTime.now()),
            )
            .watchSingle(),

        // TRANSFERS FROM ORIGIN ACCOUNTS
        db
            .countTransactions(
              predicate: predicate.copyWith(
                transactionTypes: [TransactionType.T],
                includeReceivingAccountsInAccountFilters: false,
              ).toTransactionExpression(),
              date: (exchDate ?? DateTime.now()),
            )
            .watchSingle(),

        // TRANSFERS FROM DESTINY ACCOUNTS
        db
            .countTransactions(
              predicate: predicate.copyWith(
                transactionTypes: [TransactionType.T],
                accountsIDs: null,
              ).toTransactionExpression(
                extraFilters: (transaction, account, accountCurrency,
                        receivingAccount, receivingAccountCurrency, c, p6) =>
                    [
                  if (predicate.accountsIDs != null)
                    transaction.receivingAccountID.isIn(predicate.accountsIDs!)
                ],
              ),
              date: (exchDate ?? DateTime.now()),
            )
            .watchSingle()
      ], (res) {
        return TransactionQueryStatResult(
            numberOfRes: res[0].transactionsNumber + res[1].transactionsNumber,
            valueSum: convertToPreferredCurrency
                ? res[0].sumInPrefCurrency -
                    res[1].sumInPrefCurrency +
                    res[2].sumInDestinyInPrefCurrency
                : res[0].sum - res[1].sum + res[2].sumInDestiny);
      });
    }

    // If we should not take into account transfers, we just return the normal sum
    return db
        .countTransactions(
          predicate: predicate.toTransactionExpression(),
          date: (exchDate ?? DateTime.now()),
        )
        .watchSingle()
        .map((event) => TransactionQueryStatResult(
            numberOfRes: event.transactionsNumber,
            valueSum: convertToPreferredCurrency
                ? event.sumInPrefCurrency
                : event.sum));
  }

  Stream<MoneyTransaction?> getTransactionById(String id) {
    return db
        .getTransactionsWithFullData(
          predicate: (transaction, account, accountCurrency, receivingAccount,
                  receivingAccountCurrency, c, p6) =>
              transaction.id.equals(id),
          limit: (t, a, accountCurrency, ra, receivingAccountCurrency, c, pc) =>
              Limit(1, 0),
        )
        .watchSingleOrNull();
  }

  Stream<bool> checkIfCreateTransactionIsPossible() {
    return AccountService.instance
        .getAccounts(
          predicate: (acc, curr) => AppDB.instance.buildExpr([
            acc.type.equalsValue(AccountType.saving).not(),
            acc.closingDate.isNull()
          ]),
          limit: 1,
        )
        .map((event) => event.isNotEmpty);
  }

  Future<String?> _getCategoryName(String? categoryId) async {
    if (categoryId == null) return null;
    final category = await (db.select(db.categories)
          ..where((c) => c.id.equals(categoryId)))
        .getSingleOrNull();
    return category?.name;
  }
}
