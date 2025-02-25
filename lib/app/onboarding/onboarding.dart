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
  int previousPage = 0;
  bool isFirstAccess = true;
  late AnimationController _logoController;
  late AnimationController _pageTransitionController;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _imageSlideAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<Offset> _bodyTextSlideAnimation;
  late Animation<double> _controlsFadeAnimation;
  late Animation<double> _welcomeTextFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<Offset> _pageButtonSlideAnimation;

  // Define items at class level
  final List<Map<String, String>> items = [
    {
      'header': 'Controle Financeiro\nSem Esforço',
      'description1':
          'Acreditamos que gerenciar suas finanças deve ser fácil e intuitivo.',
      'description2':
          'Deixe todo o trabalho com a gente, e aproveite seu tempo com o que realmente importa.',
      'description3': '',
      'image': 'assets/icons/onboarding/onboarding1.svg'
    },
    {
      'header': 'Trate Suas Finanças\nComo Seus Dentes',
      'description1':
          'Automatizamos tudo para facilitar sua vida, mas assim como escovar os dentes, você precisa cuidar das suas finanças todos os dias.',
      'description2': '',
      'description3': '',
      'image': 'assets/icons/onboarding/onboarding2.svg'
    },
    {
      'header': 'Metas Ambiciosas,\nResultados Reais',
      'description1':
          'Na Parsa, você define metas financeiras desafiadoras, acompanha seu progresso e transforma seus sonhos em realidade.',
      'description2':
          'Grandes conquistas começam com pequenos passos bem planejados.',
      'description3': '',
      'image': 'assets/icons/onboarding/onboarding3.svg'
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

    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      begin: const Offset(0, 3.5),
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
      begin: const Offset(0, 2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.8, 1.0, curve: Curves.elasticOut),
    ));

    _pageButtonSlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0), // Slide in from right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
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
    _pageTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Calculate responsive dimensions
    final imageHeight = size.height * 0.25;
    final contentPadding = EdgeInsets.symmetric(
      horizontal: size.width * 0.06,
      vertical: size.height * 0.02,
    );

    // Calculate the exact half of available screen height (accounting for status bar)
    final halfScreenHeight = (size.height - padding.top - padding.bottom) / 2;

    return Scaffold(
      body: SafeArea(
        child: Stack(
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
                          DisplayAppIcon(height: imageHeight),
                          SizedBox(height: size.height * 0.03),
                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: _buildWelcomeText(context, appColors),
                          ),
                        ],
                      );
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: DisplayAppIcon(height: imageHeight),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: FadeTransition(
                            opacity: _welcomeTextFadeAnimation,
                            child: _buildWelcomeText(context, appColors),
                          ),
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
                  previousPage = currentPage;
                  currentPage = index;

                  // Reset and run page transition animation when moving to/from last page
                  if ((currentPage == items.length - 1 &&
                          previousPage == items.length - 2) ||
                      (currentPage == items.length - 2 &&
                          previousPage == items.length - 1)) {
                    _pageTransitionController.reset();
                    _pageTransitionController.forward();
                  }

                  if (isFirstAccess) {
                    isFirstAccess = false;
                  }
                });
              },
              itemBuilder: (context, index) {
                final item = items[index];
                return Column(
                  children: [
                    // Top half container with fixed height for image
                    SizedBox(
                      height: halfScreenHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(height: size.height * 0.05 + 20),
                          Expanded(
                            child: Center(
                              child: isFirstAccess && index == 0
                                  ? SlideTransition(
                                      position: _imageSlideAnimation,
                                      child: _buildImage(
                                          item['image'], imageHeight),
                                    )
                                  : _buildImage(item['image'], imageHeight),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
                    ),

                    // Bottom half for text content with proper padding
                    Expanded(
                      child: Padding(
                        padding: contentPadding,
                        child: isFirstAccess && index == 0
                            ? _buildAnimatedText(item, context, size)
                            : _buildStaticText(item, context, size),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Progress Indicator at top
            Positioned(
              top: size.height * 0.02,
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
                left: size.width * 0.06,
                right: size.width * 0.06,
                bottom: padding.bottom + size.height * 0.04,
                child: previousPage == items.length - 2
                    ? SlideTransition(
                        position: _pageButtonSlideAnimation,
                        child: _buildStartJourneyButton(appColors, size),
                      )
                    : isFirstAccess
                        ? SlideTransition(
                            position: _buttonSlideAnimation,
                            child: _buildStartJourneyButton(appColors, size),
                          )
                        : _buildStartJourneyButton(appColors, size),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int itemCount, AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          itemCount,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: index == currentPage ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: index == currentPage
                  ? appColors.brandDark
                  : appColors.brandDark.withAlpha(51),
              boxShadow: index == currentPage
                  ? [
                      BoxShadow(
                        color: appColors.brandDark.withAlpha(51),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? imagePath, double height) {
    return SvgPicture.asset(
      imagePath ?? 'assets/icons/app_onboarding/first.svg',
      height: height,
      fit: BoxFit.contain,
    );
  }

  Widget _buildAnimatedText(
      Map<String, dynamic> item, BuildContext context, Size size) {
    final double headerSize = size.width * 0.055;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SlideTransition(
          position: _titleSlideAnimation,
          child: Text(
            item['header'],
            style: TextStyle(
              color: const Color(0xFF25282B),
              fontWeight: FontWeight.w900,
              fontSize: headerSize,
              fontFamily: 'Nunito',
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: size.height * 0.03),
        SlideTransition(
          position: _bodyTextSlideAnimation,
          child: Column(
            children: [
              Text(
                item['description1'],
                style: TextStyle(
                  color: const Color(0xFF25282B),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: 'Nunito',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (item['description2']!.isNotEmpty)
                SizedBox(height: size.height * 0.015),
              if (item['description2']!.isNotEmpty)
                Text(
                  item['description2']!,
                  style: TextStyle(
                    color: const Color(0xFF25282B),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (item['description3']!.isNotEmpty)
                SizedBox(height: size.height * 0.015),
              if (item['description3']!.isNotEmpty)
                Text(
                  item['description3']!,
                  style: TextStyle(
                    color: const Color(0xFF25282B),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    fontFamily: 'Nunito',
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

  Widget _buildStaticText(
      Map<String, dynamic> item, BuildContext context, Size size) {
    final double headerSize = size.width * 0.055;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          item['header'],
          style: TextStyle(
            color: const Color(0xFF25282B),
            fontWeight: FontWeight.w900,
            fontSize: headerSize,
            fontFamily: 'Nunito',
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: size.height * 0.03),
        Text(
          item['description1'],
          style: TextStyle(
            color: const Color(0xFF25282B),
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: 'Nunito',
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (item['description2']!.isNotEmpty)
          SizedBox(height: size.height * 0.015),
        if (item['description2']!.isNotEmpty)
          Text(
            item['description2']!,
            style: TextStyle(
              color: const Color(0xFF25282B),
              fontWeight: FontWeight.w400,
              fontSize: 14,
              fontFamily: 'Nunito',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        if (item['description3']!.isNotEmpty)
          SizedBox(height: size.height * 0.015),
        if (item['description3']!.isNotEmpty)
          Text(
            item['description3']!,
            style: TextStyle(
              color: const Color(0xFF25282B),
              fontWeight: FontWeight.w400,
              fontSize: 14,
              fontFamily: 'Nunito',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildStartJourneyButton(AppColors appColors, Size size) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // 3D shadow effect
          BoxShadow(
            color: appColors.brandDark.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: appColors.brandDark.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: introFinished,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, size.height * 0.065),
          backgroundColor:
              appColors.brandLight, // Using brandLight from AppColors
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
        ),
        child: Text(
          'Começar Jornada!',
          style: TextStyle(
            fontWeight: FontWeight.w900, // Nunito Black
            fontSize: size.width * 0.042, // Responsive font size
            fontFamily: 'Nunito',
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context, AppColors appColors) {
    final size = MediaQuery.of(context).size;
    final double headerSize = size.width * 0.055; // Responsive header size

    return Text(
      'Bem-vindo ao Parsa',
      style: TextStyle(
        color: const Color(0xFF25282B),
        fontWeight: FontWeight.w900, // Nunito Black
        fontSize: headerSize, // Responsive size
        fontFamily: 'Nunito',
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }
}
