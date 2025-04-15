import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parsa/main.dart';
import 'package:parsa/app/settings/subscriptions/subscription.page.dart';

class ServerHealthCheck extends StatelessWidget {
  const ServerHealthCheck({super.key});

  static Future<void> checkServerHealthAndNavigate(BuildContext context) async {
    try {
      final response = await http
          .get(Uri.parse('${apiEndpoint}/subscriptions/can-i-subscribe/'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        final int? priceMonthly = data['price_monthly'] as int?;
        final int? priceYearly = data['price_yearly'] as int?;
        
        // Navigate to PremiumWidget with the price data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PremiumWidget(
              priceMonthly: priceMonthly,
              priceYearly: priceYearly,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'O serviço de assinaturas não está disponível atualmente. Tente novamente mais tarde.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'O serviço de assinaturas não está disponível atualmente. Tente novamente mais tarde.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumWidget();
  }
}
