import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/currency/currency_service.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/main.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';

Future<void> fetchUserAccounts() async {
  final auth0Provider = Auth0Provider.instance; // Access the instance directly

  // Check if we have valid credentials
  if (auth0Provider.credentials == null) {
    // If no valid credentials, try to refresh them
    final isLoggedIn = await auth0Provider.checkLoginStatus();
    if (!isLoggedIn) {
      throw Exception('User is not logged in');
    }
  }

  

  final accessToken = auth0Provider.credentials!.accessToken;

  final response = await http.get(
    Uri.parse('$apiEndpoint/api/accounts/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    await syncAccounts(response.body);
    return json.decode(response.body);
  } else if (response.statusCode == 401) {
    // Token might be expired, try to refresh
    await auth0Provider.login();
    // Retry the request
    return fetchUserAccounts();
  } else {
    throw Exception('Failed to load user accounts: ${response.statusCode}');
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

    // Decode UTF-8 for both name and description
    final name = utf8.decode(apiAccount.name.runes.toList());
    final description = apiAccount.description != null 
        ? utf8.decode(apiAccount.description!.runes.toList())
        : null;

    Account account = Account(
      id: apiAccount.accountId,
      name: name,
      iniValue: apiAccount.iniValue ?? 0.0,
      date: apiAccount.createdAt,

      type: _mapAccountType(apiAccount.accountType),
      displayOrder: apiAccount.order, // Default or based on your logic
      iconId: apiAccount.connectorId, // Define based on your logic
      currency: currency,
      balance: apiAccount.balance ?? 0.0,
      lastUpdateTime: apiAccount.updatedAt,
      connectorID: apiAccount.connectorId,
      closingDate: apiAccount.closedAt, // Set if applicable
      description: description, // Use the decoded description
      iban: apiAccount.number.isNotEmpty ? apiAccount.number : null,
      swift: null, // Set if applicable
      color: apiAccount.primaryColor,
      isOpenFinance: apiAccount.isOpenFinance,
      removed: apiAccount.removed ?? false,
      hiddenByUser: apiAccount.hiddenByUser,
      hasMFA: apiAccount.hasMFA,
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

    //find the Auth0 context and pass it up in here: 
      
    accountService.deleteAccountLocally(idToDelete);
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
      removed: removed,
      hiddenByUser: hiddenByUser,
      hasMFA: hasMFA,
    );
  }
}
