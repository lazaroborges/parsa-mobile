import 'package:flutter/material.dart';
import 'package:parsa/app/accounts/pluggy_connector.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/core/presentation/app_colors.dart';

class SubscriptionSuccessPage extends StatelessWidget {
  const SubscriptionSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Bem-vindo ao Parsa Premium!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Parabéns! Agora você tem acesso a todas as funcionalidades premium do Parsa. Que tal começar conectando sua primeira conta bancária?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              
              const SizedBox(height: 48),
              
              // Connect Bank Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PluggyConnectorPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Conectar Conta Bancária',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Skip Button
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TabsPage(),
                    ),
                  );
                },
                child: const Text(
                  'Fazer isso depois',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}