import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/models/category/category.dart';

class PostUserTransactionService {
  static const String _apiEndpoint =
      'https://naturally-creative-boxer.ngrok-free.app/api/transaction-insert/';

  /// Serializes the [transaction] and sends it to the API.
  /// Returns [true] if the operation is successful (HTTP 200), otherwise [false].
  static Future<bool> postUserTransaction(
      TransactionInDB transaction, String accessToken) async {
    // Fetch the category using the category ID from the transaction
    final categoryStream =
        CategoryService.instance.getCategoryById(transaction.categoryID!);

    // Await the first value from the stream
    final Category? category = await categoryStream.first;

    // Print the category name or a default value if null
    print("CATEGORY NAME: ${category?.name ?? 'Unknown Category'}");

    String categoryName = category?.name ?? 'Unknown Category';

    // Serialize the transaction with the category name
    final Map<String, dynamic> transactionJson = {
      'id': transaction.id,
      'transactionDate': transaction.date.toIso8601String(),
      'amount': transaction.value,
      'notes': transaction.notes ?? '',
      'description': transaction.title ?? '',
      'status': transaction.status.toString().split('.').last,
      'account': transaction.accountID,
      'categoryName': categoryName, // Serialized Category Name
      'receivingAccountID': transaction.receivingAccountID,
      'isOpenFinance': transaction.isOpenFinance,
    };

    try {
      // Send POST request to the API
      final response = await http.post(
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
}

extension on Stream<Category?> {
  get name => null;
}
