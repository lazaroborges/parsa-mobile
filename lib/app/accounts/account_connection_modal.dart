import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/app_colors.dart';

class AccountConnectionModal extends StatefulWidget {
  const AccountConnectionModal({super.key});

  @override
  _AccountConnectionModalState createState() => _AccountConnectionModalState();
}

class _AccountConnectionModalState extends State<AccountConnectionModal> {
  bool isAutomaticSelected = true;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return Container(
      width: MediaQuery.of(context).size.width, // Responsive width
      height: MediaQuery.of(context).size.height, // Responsive height
      padding: const EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 80,
      ),
      decoration: const BoxDecoration(
        color: Color(0xB20F1728), // Semi-transparent background
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 511,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 352,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF4EBFF),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 8,
                              strokeAlign: BorderSide.strokeAlignCenter,
                              color: Color(0xFFF9F5FF),
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        // Replace FlutterLogo with your app's logo or icon if necessary
                        child: const FlutterLogo(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 76,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Criar conta',
                              style: theme.textTheme.titleLarge?.copyWith(
                                // Changed headline6 to titleLarge
                                color: appColors.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Como você prefere conectar os dados da sua conta?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: appColors
                                    .onSurface, // Use an existing color property
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 196,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOptionTile(
                              context: context,
                              icon: Icons
                                  .sync_alt_rounded, // Replace with appropriate icon
                              title: 'Automático',
                              description:
                                  'O Parsa sincroniza os dados da sua conta e categoriza as transações.',
                              isSelected: isAutomaticSelected,
                              selectedColor: appColors
                                  .primary, // Use theme's primary color
                              backgroundColor: const Color(0xFFF9F5FF),
                              onTap: () {
                                setState(() {
                                  isAutomaticSelected = true;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildOptionTile(
                              context: context,
                              icon: Icons
                                  .settings, // Replace with appropriate icon
                              title: 'Manual',
                              description:
                                  'Você atualiza os dados da sua conta e categoriza as transações.',
                              isSelected: !isAutomaticSelected,
                              selectedColor: appColors
                                  .primary, // Use theme's primary color
                              backgroundColor: Colors.white,
                              onTap: () {
                                setState(() {
                                  isAutomaticSelected = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 23),
                SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActionButton(
                        context: context,
                        label: 'Confirma',
                        isPrimary: true,
                        onPressed: () {
                          // Implement confirmation action
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        context: context,
                        label: 'Cancela',
                        isPrimary: false,
                        onPressed: () {
                          Navigator.pop(context); // Close the modal
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required Color selectedColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected ? selectedColor : const Color(0xFFD6BBFB),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: ShapeDecoration(
                color: backgroundColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: isSelected ? selectedColor : const Color(0xFFCFD4DC),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 12,
                      color: appColors.onPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          isSelected ? selectedColor : const Color(0xFF344053),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black, // Changed to black
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

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    final appColors = AppColors.of(context);

    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? appColors.primary : Colors.white,
          foregroundColor:
              isPrimary ? appColors.onPrimary : appColors.onSurface,
          side: BorderSide(
            width: 1,
            color: isPrimary ? appColors.primary : const Color(0xFFCFD4DC),
          ),
          shadowColor: const Color(0x0C101828),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? appColors.onPrimary : appColors.onSurface,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
