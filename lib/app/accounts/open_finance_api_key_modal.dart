import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/api/post_methods/post_user_settings.dart';
import 'package:parsa/core/utils/open_external_url.dart';
import 'package:flutter/gestures.dart';

class OpenFinanceApiKeyModal extends StatefulWidget {
  const OpenFinanceApiKeyModal({Key? key}) : super(key: key);

  @override
  State<OpenFinanceApiKeyModal> createState() =>
      _OpenFinanceApiKeyModalState();
}

class _OpenFinanceApiKeyModalState extends State<OpenFinanceApiKeyModal> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _submitApiKey() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await PostUserSettings.updateProviderKey(
        providerKey: _apiKeyController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chave API configurada com sucesso!'),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao configurar chave API. Tente novamente.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close the modal when tapping outside
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Color(0xB20F1728), // Semi-transparent background
        ),
        child: Stack(
          children: [
            // Center the modal content
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {}, // Prevents tap events from propagating
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: appColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x07101828),
                        blurRadius: 8,
                        offset: Offset(0, 8),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Color(0x14101828),
                        blurRadius: 24,
                        offset: Offset(0, 20),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        // Header with 'X' button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 48), // Placeholder for alignment
                            Text(
                              'Conectar com Open Finance',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: appColors.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Instructions
                        Text(
                          'Para conectar sua conta automaticamente, você precisa:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: appColors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInstructionStepWithLink(
                          context: context,
                          step: '1',
                          text: 'Acesse o ',
                          linkText: 'Pierre Finance',
                          linkUrl: 'https://pierre.finance/',
                          textAfter: ' e crie uma conta',
                        ),
                        const SizedBox(height: 8),
                        _buildInstructionStep(
                          context: context,
                          step: '2',
                          text: 'Sincronize suas contas bancárias',
                        ),
                        const SizedBox(height: 8),
                        _buildInstructionStep(
                          context: context,
                          step: '3',
                          text: 'Obtenha sua chave API nas configurações',
                        ),
                        const SizedBox(height: 24),
                        // API Key input field
                        TextFormField(
                          controller: _apiKeyController,
                          decoration: InputDecoration(
                            labelText: 'Chave API',
                            hintText: 'Cole sua chave API aqui',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: appColors.inputFill,
                          ),
                          enabled: !_isLoading,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, insira sua chave API';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitApiKey(),
                        ),
                        const SizedBox(height: 24),
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitApiKey,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColors.primary,
                              foregroundColor: appColors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Conectar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                      ),
                    ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep({
    required BuildContext context,
    required String step,
    required String text,
  }) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: appColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: theme.textTheme.bodySmall?.copyWith(
                color: appColors.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appColors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStepWithLink({
    required BuildContext context,
    required String step,
    required String text,
    required String linkText,
    required String linkUrl,
    required String textAfter,
  }) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: appColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: theme.textTheme.bodySmall?.copyWith(
                color: appColors.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: appColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(
                  text: linkText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer() 
                    ..onTap = () {
                      openExternalURL(context, linkUrl);
                    },
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.open_in_new,
                      size: 14,
                      color: appColors.primary,
                    ),
                  ),
                ),
                TextSpan(
                  text: textAfter,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

