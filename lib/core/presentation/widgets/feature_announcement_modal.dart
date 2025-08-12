import 'package:flutter/material.dart';
import 'package:parsa/core/providers/feature_announcement_provider.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    final textTheme = Theme.of(context).textTheme;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: appColors.modalBackground,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 56,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comunicado Importante',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'O serviço de assinaturas será encerrado em 29 de agosto. Nesta data nossa sincronização automática de dados será interrompida.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Para mais informações:',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acesse nossa página com detalhes completos sobre o encerramento do serviço.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: appColors.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await launchUrl(Uri.parse('https://www.parsa-ai.com.br/encerramento-subscricoes'));
                    },
                    icon: Icon(
                      Icons.info_outline,
                      color: appColors.primary,
                    ),
                    label: Text(
                      'Saber Mais',
                      style: textTheme.labelLarge,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: appColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        FeatureAnnouncementService.markAnnouncementAsSeen();
                        Navigator.of(context).pop();
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: appColors.primary,
                      ),
                      child: Text(
                        'Entendi',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: appColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: Icon(Icons.close, color: appColors.onSurface),
                style: IconButton.styleFrom(
                  backgroundColor: appColors.light,
                ),
                onPressed: () {
                  FeatureAnnouncementService.markAnnouncementAsSeen();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final appColors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: appColors.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyLarge?.copyWith(
                color: appColors.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 