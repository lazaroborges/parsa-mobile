import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/utils/check_items_availability.dart';
import 'pluggy_connector.dart';
import 'account_form.dart';

class AccountConnectionModal extends StatelessWidget {
  const AccountConnectionModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close the modal when tapping outside
      },
      child: Container(
        width: MediaQuery.of(context).size.width, // Responsive width
        height: MediaQuery.of(context).size.height, // Responsive height
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
                onTap:
                    () {}, // Prevents tap events from propagating to the background
                child: Container(
                  width: double.infinity,
                  // Adjust height as needed or make it dynamic
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: appColors.surface, // Align with app theme
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with 'X' button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                              width: 48), // Placeholder for alignment

                          Text(
                            'Criar conta',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: appColors.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context); // Close the modal
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Como você prefere conectar os dados da sua conta?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: appColors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 16),
                      // Options
                      Column(
                        children: [
                          _buildOptionTile(
                            context: context,
                            icon: Icons
                                .sync_alt_rounded, // Replace with appropriate icon

                            title: 'Automático',

                            description:
                                'O Parsa sincroniza os dados da sua conta e categoriza as transações.',
                            onTap: () async {
                              // Check Pluggy availability
                              String? errorMessage = await checkItemAvailability(context);
                              
                              if (errorMessage == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PluggyConnectorPage(),
                                  ),
                                );
                              } else {
                                // Close the modal first
                                Navigator.pop(context);
                                
                                // Show the error message in a SnackBar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                  ),
                                );
                              }
                            },
                            image: Container(
                              width: 100, // Adjust size as needed
                              height: 25, // Adjust size as needed
                              padding: const EdgeInsets.only(
                                  left: 5, right: 12, bottom: 2),
                              child: Image.asset(
                                'assets/icons/supported_selectable_icons/logos/open/logo.png',
                                fit: BoxFit.contain,
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildOptionTile(
                            context: context,
                            icon:
                                Icons.settings, // Replace with appropriate icon
                            title: 'Manual',
                            description:
                                'Você atualiza os dados da sua conta e categoriza as transações.',
                            onTap: () {
                              Navigator.pop(context); // Close the modal
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AccountFormPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    Widget? image, // Add an optional image parameter
  }) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white, // Use appropriate background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              width: 1,
              color: Color.fromARGB(161, 37, 114, 237),
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Option Icon
            Container(
              width: 20,
              height: 20,
              decoration: ShapeDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Icon(
                icon,
                color: appColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            // Option Text and Logo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Align items to the start
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: appColors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (title == 'Automático' && image != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  6.0), // Add some space between title and image
                          child: image, // Conditionally include the image
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF344053),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
