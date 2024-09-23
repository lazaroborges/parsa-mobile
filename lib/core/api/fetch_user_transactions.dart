import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:flutter/widgets.dart';

Future<Map<String, dynamic>> fetchUserTransactions(BuildContext context) async {
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
  print(response.body.length);
  //send the response to syncTransactions()

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    int objectCount = jsonResponse.length; // Count the number of objects
    print('Number of transactions: $objectCount');
    return jsonResponse;
  } else {
    throw Exception('Failed to load user accounts');
  }
}

// // I need you to extend the Transaction model and create a service to write the transactions fetched above in to the database. Here is the schema:
//         - id (UUIDField): The primary key of the transaction.
//         - date (DateTimeField): The creation date of the transaction entry in the database.
//         - transactionDate (DateTimeField): The actual date of the transaction.
//         - lastUpdateDate (DateTimeField): The last update date of the transaction at the Open Finance Server.
//         - description (CharField): A brief description of the transaction.
//         - amount (DecimalField): The amount involved in the transaction.
//         - account (ForeignKey): The account associated with the transaction.
//         - notes (TextField): Additional notes about the transaction.
//         - category (CharField): The category of the transaction.
//         - transaction_type (CharField): The type of the transaction (e.g., debit or credit).



