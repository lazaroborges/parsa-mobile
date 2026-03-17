import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/models/forecast/forecasted_transaction.dart';
import 'package:parsa/main.dart';
import 'package:parsa/core/services/auth/backend_auth_service.dart';

/// Fetches forecasts from the API for a given month.
/// [forecastMonth] must be in YYYY-MM format (e.g., "2026-03").
Future<List<ForecastedTransaction>> fetchUserForecasts(String forecastMonth) async {
  final authService = BackendAuthService.instance;
  final token = authService.token;

  if (token == null) {
    throw Exception('No authentication token found');
  }

  final url = '$apiEndpoint/api/forecasts/?forecast_month=$forecastMonth';
  print('--------Requesting Forecasts URL: $url');

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final List<dynamic> results = jsonResponse['results'] ?? [];
    print('Number of forecasts fetched: ${results.length}');
    return results
        .map((json) => ForecastedTransaction.fromJson(json as Map<String, dynamic>))
        .toList();
  } else if (response.statusCode == 401) {
    throw Exception('Authentication failed. Please log in again.');
  } else {
    print('Failed to load forecasts: ${response.statusCode} - ${response.body}');
    throw Exception('Failed to load forecasts: ${response.statusCode}');
  }
}
