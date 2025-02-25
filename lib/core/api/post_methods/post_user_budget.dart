import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/models/budget/budget.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';
import 'package:parsa/core/database/services/category/category_service.dart';

class PostUserBudget {
  static Future<bool> postBudget({
    required Budget budget,
    int maxRetries = 5,
  }) async {
    int retryCount = 0;
    int retryDelayMs = 500; // Start with 500ms delay
    
    while (true) {
      try {
        // Get auth token using Provider
        final auth0Provider = Auth0Provider.instance;
        final credentials = await auth0Provider.credentials;
        
        if (credentials == null) {
          throw Exception('User not authenticated');
        }

        // Convert Periodicity enum to string
        String? intervalPeriodString;
        if (budget.intervalPeriod != null) {
          intervalPeriodString = budget.intervalPeriod.toString().split('.').last;
        }

        // Convert category IDs to names
        List<String> categoryNames = [];
        if (budget.categories != null) {
          for (String categoryId in budget.categories!) {
            final category = await CategoryService.instance.getCategoryById(categoryId).first;
            if (category != null) {
              categoryNames.add(category.name);
            }
          }
        }

        final response = await http.post(
          Uri.parse('$apiEndpoint/budgets/'),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer ${credentials.accessToken}',
          },
          body: jsonEncode({
            'id': budget.id,
            'name': budget.name,
            'limit_amount': budget.limitAmount,
            'interval_period': intervalPeriodString,
            'start_date': budget.startDate?.toIso8601String(),
            'end_date': budget.endDate?.toIso8601String(),
            'categories': categoryNames,
            'accounts': budget.accounts,
            'tags': budget.tags,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return true;
        } else {
          throw Exception('Failed to post budget: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        print('Error posting budget (attempt $retryCount): $e');
        
        // If we've reached max retries, rethrow the exception
        if (retryCount >= maxRetries) {
          print('Max retries reached. Giving up.');
          rethrow;
        }
        
        // Exponential backoff: 500ms, 1000ms, 2000ms
        await Future.delayed(Duration(milliseconds: retryDelayMs));
        retryDelayMs *= 2; // Double the delay for next retry
        print('Retrying... (delay: ${retryDelayMs}ms)');
      }
    }
  }
}
