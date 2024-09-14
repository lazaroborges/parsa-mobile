import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/app_colors.dart';

class AccountConnectionModal extends StatelessWidget {
  const AccountConnectionModal({Key? key}) : super(key: key);

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
      decoration: BoxDecoration(
        color: const Color(0xB20F1728), // Semi-transparent background
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
              shadows: [
                BoxShadow(
                  color: const Color(0x07101828),
                  blurRadius: 8,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: const Color(0x14101828),
                  blurRadius: 24,
                  offset: const Offset(0, 20),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
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
                            side: BorderSide(
                              width: 8,
                              strokeAlign: BorderSide.strokeAlignCenter,
                              color: const Color(0xFFF9F5FF),
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        // Replace FlutterLogo with your app's logo or icon if necessary
                        child: const FlutterLogo(),
                      ),
                      const SizedBox(height: 16),
                      Container(
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
                      Container(
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
                              isSelected: true, // Adjust based on state
                              selectedColor: appColors
                                  .primary, // Use theme's primary color
                              backgroundColor: const Color(0xFFF9F5FF),
                            ),
                            const SizedBox(height: 16),
                            _buildOptionTile(
                              context: context,
                              icon: Icons
                                  .settings, // Replace with appropriate icon
                              title: 'Manual',
                              description:
                                  'Você atualiza os dados da sua conta e categoriza as transações.',
                              isSelected: false, // Adjust based on state
                              selectedColor: appColors
                                  .primary, // Use theme's primary color
                              backgroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 23),
                Container(
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
                          // Implement cancellation action
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
  }) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return Container(
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
                    color: isSelected ? selectedColor : const Color(0xFF344053),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: appColors.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          foregroundColor: isPrimary ? Colors.white : appColors.onSurface,
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
            color: isPrimary ? Colors.white : appColors.onSurface,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
