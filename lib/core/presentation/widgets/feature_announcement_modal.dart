import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:parsa/core/providers/feature_announcement_provider.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/utils/open_external_url.dart';

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
                    Icons.celebration_rounded,
                    size: 56,
                    color: appColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Estamos de volta!',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mais velozes que nunca!',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: appColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appColors.primaryContainer.withOpacity(0.3),
                      border: Border.all(color: appColors.primary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'O Parsa está de volta! E agora grátis!',
                          style: textTheme.bodyLarge?.copyWith(
                            color: appColors.onSurface,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Para usar o Parsa agora você deve obter uma chave de API Open Finance do Pierre Finance. Você pode adicionar sua chave em "Preferências"',
                          style: textTheme.bodyMedium?.copyWith(
                            color: appColors.onSurface.withOpacity(0.8),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'Você pode obter sua chave no ',
                              style: textTheme.bodyMedium?.copyWith(
                                color: appColors.onSurface.withOpacity(0.8),
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: 'site',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: appColors.primary,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      openExternalURL(context, 'https://pierre.finance/');
                                    },
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.open_in_new,
                                      size: 16,
                                      color: appColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
} 