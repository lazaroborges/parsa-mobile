// path: lib/core/api/fetch_user_transactions.dart

import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/database/services/currency/currency_service.dart';
import 'package:parsa/core/database/services/tags/tags_service.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/models/transaction/transaction_type.enum.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/core/api/serializers/transaction_serializer.dart';
import 'package:parsa/main.dart';
import 'package:parsa/app/transactions/cousin/cousin_found_dialog.dart';
import 'package:parsa/core/utils/cousin_utils.dart';
import 'package:parsa/main.dart'
    show navigatorKey; // Import the global navigator key

Future<void> fetchUserTransactions(String? accountId,
    {String? nextPageUrl, int? cousinValue, String? item}) async {
  String url;

  if (nextPageUrl != null) {
    print("Fetching next page using URL: $nextPageUrl");
    Uri nextUri = Uri.parse(nextPageUrl);
    url =
        '$apiEndpoint${nextUri.path}${nextUri.query.isEmpty ? '' : '?${nextUri.query}'}';
  } else if (item != null) {
    print("Fetching transactions for item: $item");
    url = '$apiEndpoint/api/transactions/?item=$item';
  } else if (cousinValue != null) {
    print("Fetching transactions for cousin value: $cousinValue");
    url = '$apiEndpoint/api/transactions/?cousin=$cousinValue';
  } else {
    url = '$apiEndpoint/api/transactions/';
    if (accountId != null) {
      url = '$apiEndpoint/api/transactions/$accountId/?page=1';
    }
  }

  print('--------Requesting URL: $url');

  final auth0Provider = Auth0Provider.instance;
  final credentials = await auth0Provider.credentials;

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer ${credentials?.accessToken}',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    // Extract the results field and encode it back to JSON string
    String resultsJson = json.encode(jsonResponse['results']);
    unawaited(syncTransactions(resultsJson));

    print('Count: ${jsonResponse['count']}, Next: ${jsonResponse['next']}');
    int objectCount = jsonResponse['results'].length;
    print('Number of transactions synced: $objectCount');

    if (jsonResponse['next'] != null) {
      unawaited(fetchUserTransactions(null, nextPageUrl: jsonResponse['next']));
    } else {
      await updateLastSyncTimestamp(DateTime.now());
      // Access UserDataProvider data
      final userDataProvider = UserDataProvider.instance;
      final userData = userDataProvider.userData;

      // You can now use the userData
      if (userData != null) {
        // Example: Access specific fields
        print('=================== User data: $userData');
        final hasFinished = userData['has_finished_openfinance_flow'];
        final trigger = userData['trigger_swipe_cards_flow'];

        if (hasFinished && trigger) {
          // Use the global navigator key to get context
          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            // Get cousin count for all past transactions
            final now = DateTime.now();
            final startOfTime = DateTime(
                1900, 1, 1); // Far enough back to catch all transactions
            final endOfToday =
                DateTime(now.year, now.month, now.day, 23, 59, 59);
            final cousinResult =
                await getCousinGroupSummariesForPeriod(startOfTime, endOfToday);
            final count = cousinResult.length;

            if (count > 0) {
              await CousinFoundDialog.showAndHandle(context,
                  cousinCount: count);
            }
          }
        }

        // Or access specific keys like: userData['someKey']
      }
    }
  } else {
    throw Exception('Failed to load user transactions');
  }
}

Future<void> syncTransactions(String apiResponse) async {
  try {
    // Step 1: Parse the API response
    List<ApiTransaction> apiTransactions =
        fetchAndParseTransactions(apiResponse);
    if (apiTransactions.isEmpty) {
      print('No transactions to sync.');
      return;
    }
    // Ensure all tags exist
    Set<String> allTagIds = {};
    for (var apiTransaction in apiTransactions) {
      allTagIds.addAll(apiTransaction.tags);
    }
    await ensureTagsExist(allTagIds.toList());

    // Step 2: Convert to local MoneyTransaction instances
    List<MoneyTransaction> localTransactions =
        await convertApiTransactionsToLocal(apiTransactions);
    if (localTransactions.isEmpty) {
      print('No valid transactions after conversion.');
      return;
    }

    // Step 3: Batch insert or update into the database
    await insertTransactionsIntoDB(localTransactions);

    //print('Transactions synced successfully.');
  } catch (e) {
    print('Error syncing transactions: $e');
    // Handle the error as needed
  }
}

List<ApiTransaction> fetchAndParseTransactions(String responseBody) {
  try {
    final List<dynamic> parsed = json.decode(responseBody);

    return parsed.map((json) => ApiTransaction.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Error parsing transactions: $e');
  }
}

Future<List<MoneyTransaction>> convertApiTransactionsToLocal(
    List<ApiTransaction> apiTransactions) async {
  List<MoneyTransaction> localTransactions = [];

  for (final apiTransaction in apiTransactions) {
    try {
      // Decode UTF-8 for fields that might contain special characters
      final transactionCategory = apiTransaction.transactionCategory;
      final description = apiTransaction.description ?? 'Outros';
      final paymentMethod = apiTransaction.paymentMethod;
      final notes = apiTransaction.notes;

      // Fetch currency, default to 'BRL' if not provided
      final currencyCode = apiTransaction.currency ?? 'BRL';
      CurrencyInDB? currency =
          await CurrencyService.instance.getCurrencyByCode(currencyCode).first;
      if (currency == null) {
        print(
            'Currency not found for code: $currencyCode. Skipping transaction ID: ${apiTransaction.id}');
        continue;
      }

      // Fetch account
      AccountInDB? accountInDB = await AccountService.instance
          .getAccountById(apiTransaction.account)
          .first;
      if (accountInDB == null) {
        print(
            'Account not found for ID: ${apiTransaction.account}. Skipping transaction ID: ${apiTransaction.id}');
        continue;
      }

      // Fetch category
      CategoryInDB? categoryInDB = await CategoryService.instance
          .getCategoryByName(transactionCategory)
          .first;
      if (categoryInDB == null) {
        // Try to fetch the "Outros" category
        categoryInDB =
            await CategoryService.instance.getCategoryByName("Outros").first;
        if (categoryInDB == null) {
          print(
              'Category not found for name: $transactionCategory and default "Outros" category not found. Skipping transaction ID: ${apiTransaction.id}');
          continue;
        }
        print(
            'Category not found for name: $transactionCategory. Using default "Outros" category for transaction ID: ${apiTransaction.id}');
      }

      // Fetch parent category if exists
      CategoryInDB? parentCategoryInDB;
      if (categoryInDB.parentCategoryID != null) {
        parentCategoryInDB = await CategoryService.instance
            .getCategoryById(categoryInDB.parentCategoryID!)
            .first;
        if (parentCategoryInDB == null) {
          print(
              'Parent category not found for ID: ${categoryInDB.parentCategoryID}. Skipping transaction ID: ${apiTransaction.id}');
          continue;
        }
      }

      // Determine if the category is a main category or a subcategory

      // Map transaction type
      TransactionType type =
          _mapTransactionType(apiTransaction.transactionType);

      // Map transaction status
      TransactionStatus status =
          _mapTransactionStatus(apiTransaction.considered);

      // Fetch tags from API transaction
      List<TagInDB> tagsInDB = [];
      for (final tagId in apiTransaction.tags) {
        // Fetch tag by ID
        TagInDB? tagInDB = await TagService.instance.getTagById(tagId).first;
        if (tagInDB == null) {
          print('Tag not found for ID: $tagId. Skipping this tag.');
          continue;
        }
        tagsInDB.add(tagInDB);
      }

      MoneyTransaction transaction = MoneyTransaction(
        id: apiTransaction.id,
        title: description,
        value: apiTransaction.amount,
        isHidden: apiTransaction.notes?.isNotEmpty ?? false,
        type: type,
        date: apiTransaction.transactionDate,
        account: accountInDB,
        accountCurrency: currency,
        category: categoryInDB,
        status: status,
        notes: notes,
        manipulated: apiTransaction.manipulated,
        paymentMethod: paymentMethod,
        lastUpdateTime: apiTransaction.lastUpdateTime,
        valueInDestiny: null,
        locAddress: null,
        locLatitude: null,
        locLongitude: null,
        isOpenFinance: apiTransaction.isOpenFinance,
        endDate: null,
        intervalEach: null,
        intervalPeriod: null,
        remainingTransactions: null,
        receivingAccount: null,
        cousin: apiTransaction.cousin,
        currentValueInPreferredCurrency:
            apiTransaction.amount, // Adjust as needed
        tags: tagsInDB, // Add this line
        dontAskAgain: apiTransaction.dontAskAgain ?? false,
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

TransactionStatus _mapTransactionStatus(bool? considered) {
  switch (considered) {
    case false:
      return TransactionStatus.notconsidered;
    case true:
      return TransactionStatus.reconciled;
    default:
      print(
          'Unknown transaction status: $considered. Defaulting to TransactionStatus.reconciled.');
      return TransactionStatus.reconciled; // Default status
  }
}

Future<void> insertTransactionsIntoDB(
    List<MoneyTransaction> transactions) async {
  final db = AppDB.instance;

  final transactionInDBList =
      transactions.map((tx) => tx.toTransactionInDB()).toList();

  try {
    await db.batch((batch) {
      for (var transaction in transactions) {
        // Insert or replace transaction
        batch.insert(
          db.transactions,
          transaction.toTransactionInDB(),
          mode: InsertMode.insertOrReplace,
        );

        // Insert transaction-tag associations
        for (var tag in transaction.tags) {
          batch.insert(
            db.transactionTags,
            TransactionTag(
              transactionID: transaction.id,
              tagID: tag.id,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      }
    });
    // print(
    //   'Batch insert or update successful for ${transactions.length} transactions.');
    db.markTablesUpdated([db.transactions, db.transactionTags]);
  } catch (e) {
    print('Failed to batch insert or update transactions: $e');
  }
}

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
      isOpenFinance: isOpenFinance,
      manipulated: manipulated,
      paymentMethod: paymentMethod,
      lastUpdateTime: lastUpdateTime,
      notes: notes,
      cousin: cousin,
      dontAskAgain: dontAskAgain,
    );
  }
}

Future<DateTime?> getLastSyncTimestamp() async {
  final prefs = await SharedPreferences.getInstance();
  final timestamp = prefs.getString('last_sync_timestamp');
  if (timestamp != null) {
    return DateTime.parse(timestamp);
  }
  return null;
}

Future<void> updateLastSyncTimestamp(DateTime timestamp) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_sync_timestamp', timestamp.toIso8601String());
}

Future<void> ensureTagsExist(List<String> tagIds) async {
  for (final tagId in tagIds) {
    TagInDB? tagInDB = await TagService.instance.getTagById(tagId).first;
    if (tagInDB == null) {
      // Optionally, fetch tag details from the API or create a placeholder
      // For simplicity, we'll create a placeholder tag
    }
  }
}
