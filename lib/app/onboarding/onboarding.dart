import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parsa/app/onboarding/intro.page.dart';
import 'package:parsa/core/database/services/app-data/app_data_service.dart';
import 'package:parsa/app/settings/about_page.dart';
import '../../core/presentation/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  int currentPage = 0;
  bool isFirstAccess = true;
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _imageSlideAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<Offset> _bodyTextSlideAnimation;
  late Animation<double> _controlsFadeAnimation;
  late Animation<double> _welcomeTextFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  // Define items at class level
  final List<Map<String, String>> items = [
    {
      'header': 'Controle Financeiro\nsem Esforço',
      'description1':
          'Na Parsa, acreditamos que controlar suas finanças deve ser simples e descomplicado.',
      'description2':
          'Nosso objetivo é trazer facilidade e praticidade para o seu dia a dia, permitindo que você se concentre no que realmente importa.',
      'description3':
          'Deixe o trabalho pesado conosco, enquanto você mantém o controle sem esforço.',
      'image': 'assets/icons/app_onboarding/control.svg'
    },
    {
      'header': 'Trate suas Finanças\ncomo seus Dentes',
      'description1':
          'Automatizamos ao máximo para facilitar sua vida, mas uma boa rotina financeira exige atenção.',
      'description2':
          'Assim como você cuida dos dentes todos os dias, revisar suas finanças regularmente é essencial para mantê-las saudáveis.',
      'description3': 'Faça disso um hábito simples, mas poderoso.',
      'image': 'assets/icons/app_onboarding/bend.svg'
    },
    {
      'header': 'Defina Metas Desafiadoras',
      'description1':
          'Acompanhar sua situação financeira é importante, mas para crescer, é preciso mais: metas claras e desafiadoras.',
      'description2':
          'Com a Parsa, você cria objetivos personalizados e acompanha cada passo rumo a eles.',
      'description3': 'Transforme seus sonhos financeiros em resultados.',
      'image': 'assets/icons/app_onboarding/goals.svg'
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeInOutCubicEmphasized),
    ));

    _imageSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -3.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.65, 0.9, curve: Curves.easeOutCubic),
    ));

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(3.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.65, 0.9, curve: Curves.easeOutCubic),
    ));

    _bodyTextSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 3.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
    ));

    _controlsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    ));

    _welcomeTextFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeInOutCubicEmphasized),
    ));

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 30),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
    ));

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _logoController.forward();
      }
    });
  }

  void introFinished() {
    AppDataService.instance.setAppDataItem(AppDataKey.introSeen, '1').then(
      (value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IntroPage()),
        );
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Initial Logo and Welcome Text
          if (isFirstAccess)
            Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  if (_logoController.value < 0.2) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const DisplayAppIcon(height: 200),
                        const SizedBox(height: 24),
                        _buildWelcomeText(context, appColors),
                      ],
                    );
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: const DisplayAppIcon(height: 200),
                      ),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _welcomeTextFadeAnimation,
                        child: _buildWelcomeText(context, appColors),
                      ),
                    ],
                  );
                },
              ),
            ),

          // Main Content
          PageView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: items.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
                if (isFirstAccess) {
                  isFirstAccess = false;
                }
              });
            },
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image with slide animation
                    isFirstAccess && index == 0
                        ? SlideTransition(
                            position: _imageSlideAnimation,
                            child: _buildImage(item['image']),
                          )
                        : _buildImage(item['image']),
                    const SizedBox(
                        height: 32), // Reduced spacing between image and text
                    // Title and body text
                    isFirstAccess && index == 0
                        ? _buildAnimatedText(item, context)
                        : _buildStaticText(item, context),
                  ],
                ),
              );
            },
          ),

          // Progress Indicator at top
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: isFirstAccess
                ? FadeTransition(
                    opacity: _controlsFadeAnimation,
                    child: _buildProgressIndicator(items.length, appColors),
                  )
                : _buildProgressIndicator(items.length, appColors),
          ),

          // Start Journey Button with adjusted positioning for last card
          if (currentPage == items.length - 1)
            Positioned(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom +
                  32, // Adjusted bottom padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40), // Extra spacing above button
                  SlideTransition(
                    position: _buttonSlideAnimation,
                    child: _buildStartJourneyButton(appColors),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int itemCount, AppColors appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Container(
          width: index == currentPage ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: index == currentPage
                ? appColors.brandDark
                : appColors.brandDark
                    .withAlpha(51), // Using withAlpha instead of withOpacity
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? imagePath) {
    return SvgPicture.asset(
      imagePath ?? 'assets/icons/app_onboarding/first.svg',
      height: 200,
    );
  }

  Widget _buildAnimatedText(Map<String, dynamic> item, BuildContext context) {
    final appColors = AppColors.of(context);
    final bool isLastCard = currentPage == items.length - 1;

    return Column(
      children: [
        SlideTransition(
          position: _titleSlideAnimation,
          child: Text(
            item['header'],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: appColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: isLastCard ? 24 : 28,
                  height: 1.2,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16), // Increased spacing
        SlideTransition(
          position: _bodyTextSlideAnimation,
          child: Column(
            children: [
              Text(
                item['description1'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: appColors.onSurface.withAlpha(179),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8), // Added spacing between descriptions
              Text(
                item['description2'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: appColors.onSurface.withAlpha(179),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                item['description3'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: appColors.onSurface.withAlpha(179),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaticText(Map<String, dynamic> item, BuildContext context) {
    final appColors = AppColors.of(context);
    final bool isLastCard = currentPage == items.length - 1;

    return Column(
      children: [
        Text(
          item['header'],
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: appColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: isLastCard ? 24 : 28,
                height: 1.2,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          item['description1'],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: appColors.onSurface.withAlpha(179),
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          item['description2'],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: appColors.onSurface.withAlpha(179),
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          item['description3'],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: appColors.onSurface.withAlpha(179),
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStartJourneyButton(AppColors appColors) {
    return FilledButton(
      onPressed: introFinished,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: appColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        'Começar Jornada',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: appColors.onPrimary, // Using onPrimary for better contrast
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context, AppColors appColors) {
    return Text(
      'Bem-vindo ao Parsa',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: appColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 28,
            height: 1.2,
          ),
      textAlign: TextAlign.center,
    );
  }
}
