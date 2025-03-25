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
                    Icons.celebration,
                    size: 56,
                    color: appColors.brandLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Novos Recursos!',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 24),
                  _buildFeatureItem(
                    context,
                    icon: Icons.account_balance,
                    text: 'Novas Conexões - Acesso direto às suas corretoras e à B3 para sincronização automática dos seus investimentos.',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.savings,
                    text: 'Orçamentos finalmente disponíveis! Defina metas de gastos por categoria e acompanhe seu progresso em tempo real.',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    text: 'Saldo consolidado aprimorado - Agora mostrando apenas o valor realmente disponível nas suas contas correntes.',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.calendar_today,
                    text: 'Regime de Competência: Lançamento opcional de todas as prestações na data da compra. Visite suas preferências para ativar.',
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Fique por dentro das novidades:',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entre no nosso grupo do WhatsApp para saber das novidades em primeira mão e vote nas próximas features',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: appColors.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final whatsappUrl = 'whatsapp://chat?code=GJe81VbLmEt9nbWNb2EX8C';
                      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                        await launchUrl(Uri.parse(whatsappUrl));
                      } else {
                        // Fallback to web URL if WhatsApp is not installed
                        await launchUrl(Uri.parse('https://chat.whatsapp.com/GJe81VbLmEt9nbWNb2EX8C'));
                      }
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Color(0xFF25D366),
                    ),
                    label: Text(
                      'Entrar no Grupo',
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
                        'Entendi!',
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