import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/models/category/category.dart';
import 'package:parsa/core/models/tags/tag.dart';
import 'package:parsa/main.dart';

class PostUserTransactionService {
  static String get _apiEndpoint => '$apiEndpoint/api/transaction-insert/';

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
    print("CATEGORY NAME: ${category?.name ?? 'Outros'}");

    String categoryName = category?.name ?? 'Outros';

    // Serialize the transaction with the category name and tags
    final Map<String, dynamic> transactionJson = {
      'id': transaction.id,
      'transactionDate': transaction.date.toIso8601String(),
      'amount': transaction.value,
      'notes': transaction.notes ?? '',
      'description': transaction.title ?? '',
      'considered': transaction.status.toString().split('.').last,
      'account': transaction.accountID,
      'categoryName': categoryName,
      'receivingAccountID': transaction.receivingAccountID,
      'isOpenFinance': transaction.isOpenFinance,
      'tags': tags.map((tag) => tag.id).toList(),
    };

    print("TRANSACTION JSON: $transactionJson");
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

      print('Response: ${response.body} ${response.statusCode}');

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

      print('Response: ${response.body} ${response.statusCode}');

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
