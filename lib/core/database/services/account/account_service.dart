import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:parsa/core/api/fetch_user_accounts.dart';
import 'package:parsa/core/api/fetch_user_data_server.dart';
import 'package:parsa/core/api/fetch_user_transactions.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:rxdart/rxdart.dart';
import 'package:parsa/core/api/post_methods/post_user_account.dart';
import 'package:parsa/core/api/delete_methods/delete_user_bank_account.dart';

enum AccountDataFilter { income, expense, balance }

class AccountService {
  final AppDB db;

  AccountService._(this.db);
  static final AccountService instance = AccountService._(AppDB.instance);

  /// Inserts an account after successfully posting it to the API.
  Future<int> insertAccount(AccountInDB account) async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;

      bool isPosted = await PostUserAccountService.postUserAccount(
          account, credentials?.accessToken ?? '');

      if (!isPosted) {
        throw Exception('Failed to post account to the API.');
      }

      return await db
          .into(db.accounts)
          .insert(account, mode: InsertMode.insertOrReplace);
    } catch (e) {
      print('Error inserting account: $e');
      rethrow;
    }
  }

  Future<void> insertAccountAPI(AccountInDB account) {
    return db.into(db.accounts).insertOnConflictUpdate(account);
  }

  Future<bool> updateAccount(AccountInDB account) async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;

      // Only send the order update to API if we have credentials
      if (credentials?.accessToken != null) {
        unawaited(PostUserAccountService.updateAccountOrder(
          account,
          credentials!.accessToken,
        ));
      }

      return await db.update(db.accounts).replace(account);
    } catch (e) {
      print('Error updating account: $e');
      rethrow;
    }
  }

  Future<int> deleteAccountFromLocalDB(String accountId) {
    unawaited(fetchUserDataAtServer()); // Truly non-blocking

    return (db.delete(db.accounts)..where((tbl) => tbl.id.equals(accountId)))
        .go();
  }

  Future<int> deleteAccount(String accountId) async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;

      bool isDeleted = await DeleteUserBankAccount.deleteUser(
          accountId, credentials?.accessToken ?? '');

      if (!isDeleted) {
        throw Exception('Failed to delete account from the API.');
      }
      unawaited(fetchUserDataAtServer()); // Trul
      return (db.delete(db.accounts)..where((tbl) => tbl.id.equals(accountId)))
          .go();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  Future<int> deleteAccountLocally(String accountId) async {
    try {
      return (db.delete(db.accounts)..where((tbl) => tbl.id.equals(accountId)))
          .go();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  Stream<List<Account>> getAccounts({
    Expression<bool> Function(Accounts acc, Currencies curr)? predicate,
    OrderBy Function(Accounts acc, Currencies curr)? orderBy,
    int? limit,
    int? offset,
  }) {
    return db
        .getAccountsWithFullData(
          predicate: predicate,
          orderBy: orderBy ??
              (acc, curr) => OrderBy([OrderingTerm.asc(acc.displayOrder)]),
          limit: (a, currency) => Limit(limit ?? -1, offset),
        )
        .watch();
  }

  Stream<Account?> getAccountById(String id) {
    return getAccounts(predicate: (a, c) => a.id.equals(id), limit: 1)
        .map((res) => res.firstOrNull);
  }

  String _joinAccountAndRate(DateTime? date, {String columnName = 'excRate'}) =>
      '''
    LEFT JOIN
      (
          SELECT currencyCode,
                  exchangeRate
            FROM exchangeRates er
            WHERE date = (
                            SELECT MAX(date) 
                              FROM exchangeRates
                              WHERE currencyCode = er.currencyCode 
                              ${date != null ? 'AND  date <= ?' : ''}
                          )
            ORDER BY currencyCode
      )
      AS $columnName ON accounts.currencyId = excRate.currencyCode
    ''';

  Stream<double> getAccountMoney({
    required Account account,
    DateTime? date,
    TransactionFilters trFilters = const TransactionFilters(),
    bool convertToPreferredCurrency = false,
  }) {
    return getAccountsMoney(
      accountIds: [account.id],
      date: date,
      trFilters: trFilters,
      convertToPreferredCurrency: convertToPreferredCurrency,
    );
  }

  Stream<double> getAccountsMoneyWidget({
    List<String>? accountIds,
    DateTime? date,
    TransactionFilters trFilters = const TransactionFilters(),
    bool convertToPreferredCurrency = true,
  }) {
    date ??= DateTime.now();

    final balanceQuery = db
        .customSelect(
          """
      SELECT COALESCE(SUM(
        CASE 
          WHEN accounts.type = 'credit' THEN -accounts.balance
          ELSE accounts.balance
        END
        ${convertToPreferredCurrency ? ' * COALESCE(excRate.exchangeRate, 1)' : ''}
      ), 0) AS total_balance
      FROM accounts
          ${convertToPreferredCurrency ? _joinAccountAndRate(date) : ''}
          ${accountIds != null && accountIds.isNotEmpty ? 'WHERE accounts.id IN (${List.filled(accountIds.length, '?').join(', ')})' : ''} 
      """,
          readsFrom: {
            db.accounts,
            if (convertToPreferredCurrency) db.exchangeRates,
          },
          variables: [
            if (convertToPreferredCurrency) Variable.withDateTime(date),
            if (accountIds != null && accountIds.isNotEmpty)
              for (final id in accountIds) Variable.withString(id),
          ],
        )
        .watchSingleOrNull()
        .map((res) {
          if (res?.data != null) {
            return (res!.data['total_balance'] as num).toDouble();
          }

          print('No data found for total balance.');
          return 0.0;
        });

    return balanceQuery;
  }

  Stream<double> getAccountsMoney({
    Iterable<String>? accountIds,
    DateTime? date,
    TransactionFilters trFilters = const TransactionFilters(),
    bool convertToPreferredCurrency = true,
  }) {
    date ??= DateTime.now();

    final initialBalanceQuery = db
        .customSelect(
          """
      SELECT COALESCE(SUM(accounts.iniValue ${convertToPreferredCurrency ? ' * COALESCE(excRate.exchangeRate, 1)' : ''} ), 0) AS balance
      FROM accounts
          ${convertToPreferredCurrency ? _joinAccountAndRate(date) : ''}
          ${accountIds != null && accountIds.isNotEmpty ? 'WHERE accounts.id IN (${List.filled(accountIds.length, '?').join(', ')})' : ''} 
      """,
          readsFrom: {
            db.accounts,
            if (convertToPreferredCurrency) db.exchangeRates,
          },
          variables: [
            if (convertToPreferredCurrency) Variable.withDateTime(date),
            if (accountIds != null && accountIds.isNotEmpty)
              for (final id in accountIds) Variable.withString(id),
          ],
        )
        .watchSingleOrNull()
        .map((res) {
          if (res?.data != null) {
            return (res!.data['balance'] as num).toDouble();
          }

          return 0.0;
        });

    return Rx.combineLatest([
      initialBalanceQuery,
      getAccountsBalance(
        filters: trFilters.copyWith(maxDate: date, accountsIDs: accountIds),
        convertToPreferredCurrency: convertToPreferredCurrency,
      )
    ], (res) => res[0] + res[1]);
  }

  Stream<double> getAccountsBalance({
    TransactionFilters filters = const TransactionFilters(),
    bool convertToPreferredCurrency = true,
  }) {
    filters = filters.copyWith(
        status: TransactionStatus.getStatusThatCountsForStats(filters.status));

    return TransactionService.instance
        .countTransactions(
            predicate: filters,
            exchDate: filters.maxDate ?? DateTime.now(),
            convertToPreferredCurrency: convertToPreferredCurrency)
        .map((event) => event.valueSum);
  }

  Stream<double> getAccountsMoneyVariation({
    required List<Account> accounts,
    DateTime? startDate,
    DateTime? endDate,
    bool convertToPreferredCurrency = true,
  }) {
    endDate ??= DateTime.now();
    startDate ??= accounts.map((e) => e.date).min;

    final Iterable<String> accountIds = accounts.map((e) => e.id);

    final accountsBalanceStartPeriod = getAccountsMoney(
        accountIds: accountIds,
        date: startDate,
        convertToPreferredCurrency: convertToPreferredCurrency);

    final accountsBalanceEndPeriod = getAccountsMoney(
        accountIds: accountIds,
        date: endDate,
        convertToPreferredCurrency: convertToPreferredCurrency);

    return Rx.combineLatest(
        [accountsBalanceStartPeriod, accountsBalanceEndPeriod],
        (res) => (res[1] - res[0]) / res[0]);
  }

  Future<bool> removeAccount(String accountId) async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;

      bool isRemoved = await PostUserAccountService.removeAccount(
          accountId, credentials?.accessToken ?? '');

      if (!isRemoved) {
        throw Exception('Failed to remove account from the API.');
      }

      // First delete all transactions for this account
      await (db.delete(db.transactions)
            ..where((tbl) => tbl.accountID.equals(accountId)))
          .go();

      // Then fetch and update the account
      final accountToChange = await (db.select(db.accounts)
            ..where((tbl) => tbl.id.equals(accountId)))
          .getSingle();

      // Update account status
      await db.update(db.accounts).replace(
            accountToChange.copyWith(
              removed: true,
              description: Value('Conta removida'),
              closingDate: Value(DateTime.now()),
            ),
          );

      unawaited(fetchUserDataAtServer()); // Fire and forget
      return true;
    } catch (e) {
      print('Error removing account: $e');
      return false;
    }
  }

  Future<bool> restoreAccount(String accountId) async {
    try {
      // First fetch the account
      final accountToRestore = await (db.select(db.accounts)
            ..where((tbl) => tbl.id.equals(accountId)))
          .getSingle();

      // Then update it with the new values
      await db.update(db.accounts).replace(
            accountToRestore.copyWith(
              removed: false,
              description: Value(''),
              closingDate: Value(null),
            ),
          );

      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;

      bool isRestored = await PostUserAccountService.restoreAccount(
          accountId, credentials?.accessToken ?? '');

      if (!isRestored) {
        throw Exception('Failed to restore account from the API.');
      }

      await updateRestoredAccount(accountId);
      unawaited(fetchUserDataAtServer());
      return true;
    } catch (e) {
      print('Error restoring account: $e');
      return false;
    }
  }
}

Future<void> updateRestoredAccount(String accountId) async {
  try {
    // Call the fetchUserAccounts function with the accountId
    await fetchUserAccounts();
    await fetchUserTransactions(accountId);
  } catch (e) {
    print('Error updating restored account: $e');
  }
}
