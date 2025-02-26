import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/models/budget/budget.dart';
import 'package:parsa/core/models/date-utils/periodicity.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';
import 'package:parsa/core/database/services/category/category_service.dart';

class ApiBudget {
  final String id;
  final String name;
  final double limitAmount;
  final List<String>? categories;
  final List<String>? accounts;
  final List<String>? tags;
  final String? intervalPeriod;
  final DateTime? startDate;
  final DateTime? endDate;

  ApiBudget({
    required this.id,
    required this.name,
    required this.limitAmount,
    this.categories,
    this.accounts,
    this.tags,
    this.intervalPeriod,
    this.startDate,
    this.endDate,
  });

  factory ApiBudget.fromJson(Map<String, dynamic> json) {
    return ApiBudget(
      id: json['id'],
      name: json['name'],
      limitAmount: double.parse(json['limit_amount']),
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
      accounts:
          json['accounts'] != null ? List<String>.from(json['accounts']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      intervalPeriod: json['interval_period'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }
}

Future<void> fetchUserBudgets(BuildContext context) async {
  try {
    // Get auth token directly from Auth0Provider instance
    final auth0Provider = Auth0Provider.instance;
    final credentials = await auth0Provider.credentials;
    
    if (credentials == null) {
      print('User not authenticated. Cannot fetch budgets.');
      return;
    }

    // URL for fetching user budgets
    String url = '$apiEndpoint/budgets/';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${credentials.accessToken}',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      // Explicitly decode as UTF-8
      final String decodedBody = utf8.decode(response.bodyBytes);
      
      // Sync the fetched budgets with the local database
      await syncBudgets(decodedBody);
    } else {
      print('Failed to load user budgets: ${response.statusCode}');
      throw Exception('Failed to load user budgets');
    }
  } catch (e) {
    print('Error fetching user budgets: $e');
    // Continue with local data if fetch fails
  }
}

Future<void> syncBudgets(String apiResponse) async {
  try {
    // Step 1: Parse the API response
    List<ApiBudget> apiBudgets = parseApiBudgets(apiResponse);
    if (apiBudgets.isEmpty) {
      print('No budgets to sync.');
      return;
    }

    // Step 2: Convert API budgets to local Budget model
    List<Budget> localBudgets = convertBudgetsToLocal(apiBudgets);
    if (localBudgets.isEmpty) {
      print('No valid budgets after conversion.');
      return;
    }

    // Step 3: Batch insert or update the budgets in the local database
    await insertBudgetsIntoDB(localBudgets);

    print('Budgets synced successfully.');
  } catch (e) {
    print('Error syncing budgets: $e');
  }
}

List<ApiBudget> parseApiBudgets(String responseBody) {
  try {
    final List<dynamic> parsed = json.decode(responseBody);
    return parsed.map((json) => ApiBudget.fromJson(json)).toList();
  } catch (e) {
    print('Error parsing budgets: $e');
    return [];
  }
}

List<Budget> convertBudgetsToLocal(List<ApiBudget> apiBudgets) {
  List<Budget> localBudgets = [];

  for (final apiBudget in apiBudgets) {
    try {
      // Convert string intervalPeriod to Periodicity enum
      Periodicity? periodicity;
      if (apiBudget.intervalPeriod != null) {
        // Try to convert the string to Periodicity enum
        try {
          // This matches how we handle it in post_user_budget.dart but in reverse
          // We're converting from string to enum
          periodicity = Periodicity.values.firstWhere(
            (e) => e.toString().split('.').last == apiBudget.intervalPeriod,
          );
        } catch (e) {
          print('Error converting intervalPeriod: ${apiBudget.intervalPeriod}');
          // Default to null if conversion fails
          periodicity = null;
        }
      }

      // Create a local Budget instance from the API budget data
      Budget budget = Budget(
        id: apiBudget.id,
        name: apiBudget.name,
        limitAmount: apiBudget.limitAmount,
        categories: apiBudget.categories,
        accounts: apiBudget.accounts,
        tags: apiBudget.tags,
        intervalPeriod: periodicity,
        startDate: apiBudget.startDate,
        endDate: apiBudget.endDate,
      );

      localBudgets.add(budget);
    } catch (e) {
      print('Error processing budget ID: ${apiBudget.id}: $e');
      // Continue processing other budgets
      continue;
    }
  }

  return localBudgets;
}

Future<void> insertBudgetsIntoDB(List<Budget> budgets) async {
  final budgetService = BudgetServive.instance;
  final categoryService = CategoryService.instance;
  
  for (final budget in budgets) {
    try {
      // Check if budget already exists
      final existingBudget = await budgetService.getBudgetById(budget.id).first;
      
      // Create a copy of the budget without categories to avoid foreign key constraint errors
      Budget budgetWithoutCategories = Budget(
        id: budget.id,
        name: budget.name,
        limitAmount: budget.limitAmount,
        categories: null, // Set to null to avoid foreign key issues
        accounts: budget.accounts,
        tags: budget.tags,
        intervalPeriod: budget.intervalPeriod,
        startDate: budget.startDate,
        endDate: budget.endDate,
      );
      
      // First insert/update the budget without categories
      if (existingBudget != null) {
        await budgetService.updateBudget(budgetWithoutCategories, skipServerSync: true);
      } else {
        await budgetService.insertBudget(budgetWithoutCategories, skipServerSync: true);
      }
      
      // Now handle the categories - map category names to IDs
      if (budget.categories != null && budget.categories!.isNotEmpty) {
        List<String> categoryIds = [];
        
        // For each category name, find the corresponding category ID
        for (String categoryName in budget.categories!) {
          final category = await categoryService.getCategoryByName(categoryName).first;
          if (category != null) {
            categoryIds.add(category.id);
            
            // Insert the budget-category relationship
            await budgetService.db.into(budgetService.db.budgetCategory).insert(
              BudgetCategoryData(
                budgetID: budget.id,
                categoryID: category.id
              )
            );
          } else {
            print('Category not found for name: $categoryName');
          }
        }
        
        print('Mapped categories for budget ${budget.id}: ${categoryIds.length} of ${budget.categories!.length} found');
      }
    } catch (e) {
      print('Error saving budget ${budget.id}: $e');
    }
  }
} 