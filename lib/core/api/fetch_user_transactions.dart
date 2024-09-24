import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';

// Import your local dependencies
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/database/services/currency/currency_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/models/transaction/transaction_type.enum.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/core/api/serializers/transaction_serializer.dart';

Future<void> fetchUserTransactions(BuildContext context) async {
  final auth0 = Auth0Provider.of(context)!.auth0;

  final credentials = await auth0.credentialsManager.credentials();

  final response = await http.get(
    Uri.parse(
        'https://naturally-creative-boxer.ngrok-free.app/api/transactions/'),
    headers: {
      'Authorization': 'Bearer ${credentials.accessToken}',
      'Content-Type': 'application/json',
    },
  );

  await syncTransactions(
      response.body); // Send the response to syncTransactions()

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    int objectCount = jsonResponse.length; // Count the number of objects
    print('Number of transactions: $objectCount');
    return jsonResponse;
  } else {
    throw Exception('Failed to load user transactions');
  }
}

/// Synchronizes transactions by parsing, converting, and inserting them into the local database.
Future<void> syncTransactions(String apiResponse) async {
  try {
    // Step 1: Parse the API response
    List<ApiTransaction> apiTransactions =
        fetchAndParseTransactions(apiResponse);
    if (apiTransactions.isEmpty) {
      print('No transactions to sync.');
      return;
    }

    // Step 2: Convert to local MoneyTransaction instances
    List<MoneyTransaction> localTransactions =
        await convertApiTransactionsToLocal(apiTransactions);
    if (localTransactions.isEmpty) {
      print('No valid transactions after conversion.');
      return;
    }

    // Step 3: Insert into the database
    await insertTransactionsIntoDB(localTransactions);

    print('Transactions synced successfully.');
  } catch (e, stackTrace) {
    // Consider logging the stackTrace as well for debugging
    print('Error syncing transactions: $e');
    // You might want to rethrow or handle the error appropriately based on your app's needs
    // throw e;
  }
}

/// Parses the API response and returns a list of ApiTransaction objects.
List<ApiTransaction> fetchAndParseTransactions(String responseBody) {
  try {
    final List<dynamic> parsed = json.decode(responseBody);

    return parsed.map((json) => ApiTransaction.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Error parsing transactions: $e');
  }
}

/// Converts a list of ApiTransaction objects to MoneyTransaction instances.
Future<List<MoneyTransaction>> convertApiTransactionsToLocal(
    List<ApiTransaction> apiTransactions) async {
  List<MoneyTransaction> localTransactions = [];

  for (final apiTransaction in apiTransactions) {
    try {
      // Fetch currency, default to 'BRL' if not provided
      final currencyCode = apiTransaction.currency ?? 'BRL';
      CurrencyInDB? currency =
          await CurrencyService.instance.getCurrencyByCode(currencyCode).first;
      if (currency == null) {
        print(
            'Currency not found for code: $currencyCode. Skipping transaction ID: ${apiTransaction.id}');
        continue; // Skip this transaction
      }

      // Fetch account
      AccountInDB? accountInDB = await AccountService.instance
          .getAccountById(apiTransaction.account)
          .first;
      if (accountInDB == null) {
        print(
            'Account not found for ID: ${apiTransaction.account}. Skipping transaction ID: ${apiTransaction.id}');
        continue; // Skip this transaction
      }

      // Fetch category
      CategoryInDB? categoryInDB = await CategoryService.instance
          .getCategoryByName(apiTransaction.transactionCategory)
          .first;
      if (categoryInDB == null) {
        print(
            'Category not found for name: ${apiTransaction.transactionCategory}. Skipping transaction ID: ${apiTransaction.id}');
        continue; // Skip this transaction
      }

      // Map transaction type
      TransactionType type =
          _mapTransactionType(apiTransaction.transactionType);

      // Map transaction status
      TransactionStatus status = _mapTransactionStatus(apiTransaction.status);

      // Create MoneyTransaction instance
      MoneyTransaction transaction = MoneyTransaction(
        id: apiTransaction.id,
        title: apiTransaction.description ?? 'No Description',
        value: apiTransaction.amount,
        isHidden: apiTransaction.notes?.isNotEmpty ?? false,
        type: type,
        date: apiTransaction.transactionDate,
        account: accountInDB,
        accountCurrency: currency,
        category: categoryInDB,
        status: status,
        // Provide other required arguments with default values or null where appropriate
        valueInDestiny: null,
        locAddress: null,
        locLatitude: null,
        locLongitude: null,
        endDate: null,
        intervalEach: null,
        intervalPeriod: null,
        remainingTransactions: null,
        receivingAccount: null,
        currentValueInPreferredCurrency:
            apiTransaction.amount, // Adjust as needed
        tags: [],
      );

      localTransactions.add(transaction);
    } catch (e) {
      print('Error processing transaction ID: ${apiTransaction.id}: $e');
      // Decide whether to continue with next transactions or halt
      continue;
    }
  }

  return localTransactions;
}

/// Maps the string transaction type from API to the TransactionType enum.
TransactionType _mapTransactionType(String type) {
  switch (type.toLowerCase()) {
    case 'credit':
      return TransactionType.I;
    case 'debit':
      return TransactionType.E;
    default:
      print(
          'Unknown transaction type: $type. Defaulting to TransactionType.E.');
      return TransactionType.E; // Default type
  }
}

/// Maps the string transaction status from API to the TransactionStatus enum.
TransactionStatus _mapTransactionStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
      return TransactionStatus.pending;
    case 'posted':
      return TransactionStatus.reconciled;
    default:
      print(
          'Unknown transaction status: $status. Defaulting to TransactionStatus.reconciled.');
      return TransactionStatus.reconciled; // Default status
  }
}

/// Inserts a list of MoneyTransaction objects into the local database.
Future<void> insertTransactionsIntoDB(
    List<MoneyTransaction> transactions) async {
  for (final transaction in transactions) {
    try {
      await TransactionService.instance
          .insertTransaction(transaction.toTransactionInDB());
    } catch (e) {
      print('Failed to insert transaction ID: ${transaction.id} into DB: $e');
      // Depending on requirements, you might want to continue or halt
      continue;
    }
  }
}

/// Extension to convert MoneyTransaction to TransactionInDB.
extension MoneyTransactionExtension on MoneyTransaction {
  TransactionInDB toTransactionInDB() {
    if (category == null) {
      throw Exception('Category cannot be null for TransactionInDB.');
    }

    return TransactionInDB(
      id: id,
      title: title,
      value: value,
      isHidden: isHidden,
      type: type,
      date: date,
      accountID: account.id,
      categoryID: category!.id,
      status: status,
      // Include other required fields here...
      // Ensure all non-nullable fields are provided
    );
  }
}
