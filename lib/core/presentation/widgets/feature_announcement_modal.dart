import 'package:flutter/material.dart';
import 'package:parsa/core/providers/feature_announcement_provider.dart';
import 'package:parsa/core/presentation/app_colors.dart';

class FeatureAnnouncementModal extends StatelessWidget {
  const FeatureAnnouncementModal({Key? key}) : super(key: key);

  static Future<void> showIfNeeded(BuildContext context) async {
    if (!(await FeatureAnnouncementService.hasSeenAnnouncement())) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => const FeatureAnnouncementModal(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 48,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Image.asset(
              'assets/resources/feature.gif',
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'Nova Funcionalidade! \n Saldos Diferenciados.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Agora você pode ver os saldos agregados por diferentes tipos de contas. Basta clicar no saldo para ver as duas novas opções.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  FeatureAnnouncementService.markAnnouncementAsSeen();
                  Navigator.of(context).pop();
                },
                child: const Text('Entendi!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 