import 'package:flutter/material.dart';

class PremiumWidget extends StatefulWidget {
  @override
  _PremiumWidgetState createState() => _PremiumWidgetState();
}

class _PremiumWidgetState extends State<PremiumWidget> {
  String? selectedPlan;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top container with background image
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/resources/container_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 8), // Add status bar height + extra padding
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255), ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(), // This pushes the header to center
                      Image.asset(
                        'assets/resources/header.png',
                        height: 40,
                      ),
                      const Spacer(), // This maintains the center position
                      const SizedBox(width: 48), // Same width as IconButton for balance
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Image.asset(
                      'assets/resources/app_image.png',
                      height: screenHeight * 0.3 > 280 ? 280 : screenHeight * 0.3,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            
            // Rest of the content with original padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'Parsa Premium - Teste por 7 dias com direito a reembolso total',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0F1728),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    'Integração via Open Finance com até 3 contas, sincronização automática, insights precisos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF475466),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Plans
                  Column(
                    children: [
                      // Monthly Plan
                      GestureDetector(
                        onTap: () => setState(() => selectedPlan = 'monthly'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: selectedPlan == 'monthly' ? Color(0xFFF9F5FF) : Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: selectedPlan == 'monthly' ? Color(0xFFD6BBFB) : Color(0xFFE4E7EC),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Plano Mensal',
                                style: TextStyle(
                                  color: selectedPlan == 'monthly' ? Color(0xFF52379E) : Color(0xFF344053),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'R\$24,90/mês',
                                style: TextStyle(
                                  color: selectedPlan == 'monthly' ? Color(0xFF7E56D8) : Color(0xFF667084),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Annual Plan
                      GestureDetector(
                        onTap: () => setState(() => selectedPlan = 'annual'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: selectedPlan == 'annual' ? Color(0xFFF9F5FF) : Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: selectedPlan == 'annual' ? Color(0xFFD6BBFB) : Color(0xFFE4E7EC),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        text: 'Plano Anual ',
                                        style: TextStyle(
                                          color: selectedPlan == 'annual' ? Color(0xFF52379E) : Color(0xFF344053),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'R\$20,82/mês*',
                                            style: TextStyle(
                                              color: selectedPlan == 'annual' ? Color(0xFF7E56D8) : Color(0xFF667084),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '*Cobrança anual única de R\$249,90',
                                      style: TextStyle(
                                        color: selectedPlan == 'annual' ? Color(0xFF7E56D8) : Color(0xFF667084),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Premium Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7E56D8), // Update button color
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Seja Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Extra spacing at the bottom
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}