import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/models/category/category.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/models/tags/tag.dart';
import 'package:parsa/main.dart';

class PostUserTransactionService {
  static String get _apiEndpoint => '$apiEndpoint/api/transactions/update';

  static Future<bool> postUserTransaction(
      {required TransactionInDB transaction,
      required String accessToken,
      required List<Tag> tags,
      String? method = 'POST'}) async {
    // Fetch the category using the category ID or default to '85' if null
    final categoryStream = CategoryService.instance
        .getCategoryById(transaction.categoryID ?? '85');

    // Await the first value from the stream
    final Category? category = await categoryStream.first;

    // Print the category name or a default value if null

    String categoryName = category?.name ?? 'Outros';

    // Serialize the transaction with the category name and tags
    // Map status to boolean: reconciled -> true, notconsidered -> false
    bool? consideredValue;
    if (transaction.status == TransactionStatus.reconciled) {
      consideredValue = true;
    } else if (transaction.status == TransactionStatus.notconsidered) {
      consideredValue = false;
    }

    final Map<String, dynamic> transactionJson = {
      'id': transaction.id,
      'transactionDate': transaction.date.toIso8601String(),
      'amount': transaction.value,
      'notes': transaction.notes ?? '',
      'description': transaction.title ?? '',
      'considered': consideredValue,
      'account': transaction.accountID,
      'category': categoryName,
      'receivingAccountID': transaction.receivingAccountID,
      'isOpenFinance': transaction.isOpenFinance,
      'tags': tags.map((tag) => tag.id).toList(),
    };

    try {
      // Send POST request to the API
      final response = method == 'POST'
          ? await http.post(
              Uri.parse(_apiEndpoint),
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'application/json',
              },
              body: json.encode(transactionJson),
            )
          : await http.put(
              Uri.parse(_apiEndpoint),
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'application/json',
              },
              body: json.encode(transactionJson),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(
            'Failed to post transaction. Status Code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error posting transaction: $e');
      return false;
    }
  }

  /// PATCH method that sends only changed fields for partial updates
  static Future<bool> patchUserTransaction({
    required String transactionId,
    required TransactionChanges changes,
    required String accessToken,
  }) async {
    if (!changes.hasChanges) {
      return true; // Nothing to update
    }

    // Build payload with only changed fields
    final Map<String, dynamic> transactionUpdate = {
      'id': transactionId,
      ...changes.toJson(),
    };

    // Wrap in "transactions" array to match backend expectation
    final Map<String, dynamic> patchJson = {
      'transactions': [transactionUpdate],
    };

    try {
      final response = await http.patch(
        Uri.parse(_apiEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(patchJson),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print(
            'Failed to patch transaction. Status Code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error patching transaction: $e');
      return false;
    }
  }

  /// Batch POST method that sends multiple transactions wrapped in a "transactions" array
  static Future<bool> postBatchTransactions({
    required List<TransactionInDB> transactions,
    required Map<String, List<Tag>> transactionTags, // Map of transactionId -> tags
    required String accessToken,
  }) async {
    if (transactions.isEmpty) {
      return true; // Nothing to send
    }

    // Serialize all transactions
    List<Map<String, dynamic>> transactionsJson = [];
    
    for (var transaction in transactions) {
      // Fetch the category for this transaction
      final categoryStream = CategoryService.instance
          .getCategoryById(transaction.categoryID ?? '85');
      final Category? category = await categoryStream.first;
      String categoryName = category?.name ?? 'Outros';

      // Get tags for this transaction
      final tags = transactionTags[transaction.id] ?? [];

      // Serialize transaction using the same format as postUserTransaction
      transactionsJson.add({
        'id': transaction.id,
        'transactionDate': transaction.date.toIso8601String(),
        'amount': transaction.value,
        'notes': transaction.notes ?? '',
        'description': transaction.title ?? '',
        'considered': transaction.status.toString().split('.').last,
        'account': transaction.accountID,
        'category': categoryName,
        'receivingAccountID': transaction.receivingAccountID,
        'isOpenFinance': transaction.isOpenFinance,
        'tags': tags.map((tag) => tag.id).toList(),
      });
    }

    // Wrap in "transactions" key
    final Map<String, dynamic> batchJson = {
      'transactions': transactionsJson,
    };

    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(batchJson),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(
            'Failed to post batch transactions. Status Code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error posting batch transactions: $e');
      return false;
    }
  }

  static Future<bool> deleteUserTransaction(
      String transactionId, String accessToken) async {
    try {
      // Prepare the JSON body with the transaction ID
      final Map<String, dynamic> body = {
        'id': transactionId,
      };

      // Send DELETE request with the body
      final response = await http.delete(
        Uri.parse(_apiEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(body), // Include the body in the request
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print(
            'Failed to delete transaction. Status Code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }
}

extension on Stream<Category?> {
  get name => null;
}
