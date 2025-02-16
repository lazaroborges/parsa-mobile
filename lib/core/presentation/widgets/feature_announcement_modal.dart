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
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
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
                  Text(
                    'Novos Recursos!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureItem(
                    context,
                    icon: Icons.edit,
                    text: 'Você agora pode editar a quantia das transações sincronizadas. Basta clicar sobre o valor da transação.',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.percent,
                    text: 'Barra de Progresso com Percentual da Receita Gasta',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.list,
                    text: 'A Lista de Contas agora é vertical. Você pode ordernar como quiser e ocultar as que você não quer ver puxando a conta para as laterais',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.select_all,
                    text: 'Edite transações em massa por meio dos filtros. Basta aplicar um dos filtros e clicar no novo botão de seleção.',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Fique por dentro das novidades:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Entre no nosso grupo do WhatsApp para saber das novidades em primeira mão e vote nas próximas features',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.2),
                  ),
                  const SizedBox(height: 12),
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
                    label: const Text('Entrar no Grupo'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
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
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
} 