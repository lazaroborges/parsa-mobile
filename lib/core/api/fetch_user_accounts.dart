import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:flutter/widgets.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/currency/currency_service.dart';
import 'package:parsa/core/database/app_db.dart';

Future<void> fetchUserAccounts(BuildContext context) async {
  final auth0 = Auth0Provider.of(context)!.auth0;

  final credentials = await auth0.credentialsManager.credentials();

  final response = await http.get(
    Uri.parse('https://naturally-creative-boxer.ngrok-free.app/api/accounts/'),
    headers: {
      'Authorization': 'Bearer ${credentials.accessToken}',
      'Content-Type': 'application/json',
    },
  );

  //send the response to syncAccounts()
  await syncAccounts(response.body);

  if (response.statusCode == 200) {
    //iterate over the response body and print each account in a new line

    return json.decode(response.body);
  } else {
    throw Exception('Failed to load user accounts');
  }
}

Future<void> syncAccounts(String apiResponse) async {
  try {
    // Step 1: Parse the API response
    List<ApiAccount> apiAccounts = await fetchAndParseAccounts(apiResponse);

    // Step 2: Convert to local Account instances
    List<Account> localAccounts = await convertApiAccountsToLocal(apiAccounts);

    // Step 3: Insert into the database
    await insertAccountsIntoDB(localAccounts);

    print('Accounts synced successfully.');
  } catch (e) {
    print('Error syncing accounts: $e');
    // Handle error appropriately
  }
}

Future<List<ApiAccount>> fetchAndParseAccounts(String responseBody) async {
  final List<dynamic> parsed = json.decode(responseBody);
  return parsed.map((json) => ApiAccount.fromJson(json)).toList();
}

Future<List<Account>> convertApiAccountsToLocal(
    List<ApiAccount> apiAccounts) async {
  List<Account> localAccounts = [];

  for (final apiAccount in apiAccounts) {
    // Fetch or define the currency. Here, assuming 'BRL' as default.
    CurrencyInDB currency = (await CurrencyService.instance
        .getCurrencyByCode('BRL')
        .first) as CurrencyInDB;

    Account account = Account(
      id: apiAccount.accountId,
      name: apiAccount.name,
      iniValue: apiAccount.balance ?? 0.0,
      date: apiAccount.createdAt,

      type: _mapAccountType(apiAccount.accountType),
      displayOrder: 10, // Default or based on your logic
      iconId: apiAccount.connectorId, // Define based on your logic
      currency: currency,
      balance: apiAccount.balance ?? 0.0,
      lastUpdateTime: apiAccount.updatedAt,
      connectorID: apiAccount.connectorId,
      closingDate: apiAccount.closedAt, // Set if applicable
      description: null, // Set if applicable
      iban: apiAccount.number.isNotEmpty ? apiAccount.number : null,
      swift: null, // Set if applicable
      color: apiAccount.primaryColor,
      isOpenFinance: apiAccount.isOpenFinance,
    );

    localAccounts.add(account);
  }

  return localAccounts;
}

AccountType _mapAccountType(String type) {
  switch (type.toLowerCase()) {
    case 'normal':
      return AccountType.normal;
    case 'credit':
      return AccountType.credit;
    case 'saving':
      return AccountType.saving;
    default:
      return AccountType.normal; // Default type
  }
}

Future<void> insertAccountsIntoDB(List<Account> accounts) async {
  final db = AppDB.instance;
  final accountService = AccountService.instance;

  // Get all existing account IDs from the database
  final existingAccountIds =
      await db.select(db.accounts).map((a) => a.id).get();

  // Get all account IDs from the API response
  final apiAccountIds = accounts.map((a) => a.id).toSet();

  // Find account IDs that are in the database but not in the API response
  final accountIdsToDelete =
      existingAccountIds.where((id) => !apiAccountIds.contains(id));

  // Delete accounts that are not in the API response from the local database
  for (final idToDelete in accountIdsToDelete) {
    accountService.deleteAccountFromLocalDB(idToDelete);
  }

  // Insert or update accounts from the API
  for (final account in accounts) {
    await accountService.insertAccountAPI(account.toAccountInDB());
  }

  // Mark the accounts table as updated
  db.markTablesUpdated([db.accounts]);
}

// Extension to convert Account to AccountInDB
extension AccountExtension on Account {
  AccountInDB toAccountInDB() {
    return AccountInDB(
      id: id,
      name: name,
      iniValue: iniValue,
      date: date,
      type: type,
      displayOrder: displayOrder,
      iconId: iconId,
      currencyId: currency.code,
      balance: balance,
      lastUpdateTime: lastUpdateTime,
      connectorID: connectorID,
      closingDate: closingDate,
      description: description,
      iban: iban,
      swift: swift,
      color: color,
      isOpenFinance: isOpenFinance,
    );
  }
}
