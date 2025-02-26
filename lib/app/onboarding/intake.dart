import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/app/onboarding/question_styles.dart';
import 'package:parsa/app/layout/tabs.dart';

final GlobalKey<TabsPageState> tabsPageKey = GlobalKey<TabsPageState>();

class IntakeForm extends StatefulWidget {
  const IntakeForm({Key? key}) : super(key: key);

  @override
  _IntakeFormState createState() => _IntakeFormState();
}

class _IntakeFormState extends State<IntakeForm> with TickerProviderStateMixin {
  List<dynamic>? questions;
  int currentQuestionIndex = 0;
  Map<String, dynamic> answers = {};
  Map<String, dynamic>? currentConditionalQuestion;
  bool isLoading = true;
  bool isCurrentQuestionValid = false;

  // Animation controllers
  late AnimationController _pageTransitionController;
  late Animation<Offset> _forwardSlideAnimation;
  late Animation<Offset> _backwardSlideAnimation;

  // Track previous question for animation direction
  int previousQuestionIndex = 0;
  bool get isForwardNavigation => currentQuestionIndex > previousQuestionIndex;

  // Flag to prevent setState during build
  bool _isBuilding = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initialize();
  }

  void _initializeAnimations() {
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Slide in from right animation (for moving forward)
    _forwardSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    ));

    // Slide in from left animation (for moving backward)
    _backwardSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await loadQuestions();
    setState(() {
      isLoading = false;
    });
    // Start with animation completed
    _pageTransitionController.value = 1.0;
  }

  Future<void> loadQuestions() async {
    try {
      final String questionsJson = await DefaultAssetBundle.of(context)
          .loadString('lib/app/onboarding/questions.json');
      setState(() {
        final data = json.decode(questionsJson);
        questions = data['questions'];
      });
    } catch (e) {
      print('Error loading questions: $e');
      // Fallback to empty list
      setState(() {
        questions = [];
      });
    }
  }

  void saveAnswer(String questionId, dynamic answer) {
    if (!mounted) return;

    setState(() {
      answers[questionId] = answer;
    });
  }

  void completeIntakeForm() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TabsPage(key: tabsPageKey),
        ),
      );
    }
  }

  void moveToNextQuestion() {
    if (!isCurrentQuestionValid) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (currentConditionalQuestion != null) {
        setState(() {
          currentConditionalQuestion = null;
          previousQuestionIndex = currentQuestionIndex;
          currentQuestionIndex++;
        });
        _pageTransitionController.forward(from: 0.0);
        return;
      }

      final currentQuestion = questions![currentQuestionIndex];
      if (currentQuestion.containsKey('conditional_questions')) {
        final questionId = currentQuestion['id'];
        final answer = answers[questionId];

        if (answer != null &&
            currentQuestion['conditional_questions'].containsKey(answer)) {
          setState(() {
            currentConditionalQuestion =
                currentQuestion['conditional_questions'][answer];
          });
          _pageTransitionController.forward(from: 0.0);
          return;
        }
      }

      if (currentQuestionIndex < questions!.length - 1) {
        setState(() {
          previousQuestionIndex = currentQuestionIndex;
          currentQuestionIndex++;
          isCurrentQuestionValid = false;
        });
        _pageTransitionController.forward(from: 0.0);
      } else {
        completeIntakeForm();
      }
    });
  }

  void moveToPreviousQuestion() {
    if (currentQuestionIndex == 0 && currentConditionalQuestion == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (currentConditionalQuestion != null) {
        setState(() {
          currentConditionalQuestion = null;
          _pageTransitionController.forward(from: 0.0);
        });
      } else {
        final newIndex = currentQuestionIndex - 1;
        setState(() {
          previousQuestionIndex = currentQuestionIndex;
          currentQuestionIndex = newIndex;
          final questionId = questions![newIndex]['id'];
          isCurrentQuestionValid = answers.containsKey(questionId);
          _pageTransitionController.forward(from: 0.0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _isBuilding = true;

    if (isLoading || questions == null || questions!.isEmpty) {
      _isBuilding = false;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.of(context).brand,
          ),
        ),
      );
    }

    final currentQuestion =
        currentConditionalQuestion ?? questions![currentQuestionIndex];
    final canGoBack =
        currentQuestionIndex > 0 || currentConditionalQuestion != null;

    final appColors = AppColors.of(context);
    final totalQuestions = questions?.length ?? 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.05;
    final verticalPadding = screenHeight * 0.015;
    final dotWidth = screenWidth * 0.02;
    final activeDotWidth = screenWidth * 0.06;
    final dotHeight = screenHeight * 0.01;
    final dotSpacing = screenWidth * 0.008;

    // Reset the building flag after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isBuilding = false;
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots and back button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      size: screenWidth * 0.06,
                      color: canGoBack
                          ? appColors.brandLight
                          : appColors.brandLight.withAlpha(51),
                    ),
                    onPressed: canGoBack ? moveToPreviousQuestion : null,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        totalQuestions,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: index == currentQuestionIndex
                              ? activeDotWidth
                              : dotWidth,
                          height: dotHeight,
                          margin: EdgeInsets.symmetric(horizontal: dotSpacing),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: index == currentQuestionIndex
                                ? appColors.brand
                                : appColors.brand.withAlpha(51),
                            boxShadow: index == currentQuestionIndex
                                ? [
                                    BoxShadow(
                                      color: appColors.brand.withAlpha(51),
                                      offset: Offset(0, screenHeight * 0.001),
                                      blurRadius: screenWidth * 0.005,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.1),
                ],
              ),
            ),
            // Question content and next button
            Expanded(
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _pageTransitionController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: isForwardNavigation
                            ? _forwardSlideAnimation
                            : _backwardSlideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: buildQuestion(currentQuestion),
                          ),
                        ),
                      );
                    },
                  ),
                  // Continue button
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isCurrentQuestionValid
                            ? [
                                BoxShadow(
                                  color: appColors.brand.withOpacity(0.3),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: appColors.brand.withOpacity(0.1),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      margin: const EdgeInsets.all(20),
                      child: Material(
                        color: Colors.transparent,
                        child: ElevatedButton(
                          onPressed: isCurrentQuestionValid
                              ? moveToNextQuestion
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrentQuestionValid
                                ? appColors.brand
                                : Colors.grey.shade200,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Continuar',
                            style: TextStyle(
                              color: isCurrentQuestionValid
                                  ? Colors.white
                                  : Colors.grey.shade500,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              fontFamily: 'Nunito',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
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

  Widget buildQuestion(Map<String, dynamic> question) {
    final questionId = question['id'];
    final savedAnswer = answers[questionId];

    // Check validity without immediate setState
    final bool questionHasAnswer = answers.containsKey(questionId);

    // Only schedule an update if needed and not during build
    if (questionHasAnswer != isCurrentQuestionValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isBuilding) {
          setState(() {
            isCurrentQuestionValid = questionHasAnswer;
          });
        }
      });
    }

    // Create question widget based on question type
    switch (question['type']) {
      case 'single_choice':
        return SingleChoiceQuestion(
          question: question,
          initialAnswer: savedAnswer as String?,
          onAnswer: (answer) {
            _safeStateUpdate(() => saveAnswer(questionId, answer));
          },
          onValidityChanged: (isValid) {
            _safeStateUpdate(() {
              setState(() => isCurrentQuestionValid = isValid);
            });
          },
        );
      case 'multiple_choice':
        List<String>? initialAnswers;
        if (savedAnswer != null) {
          if (savedAnswer is List) {
            initialAnswers = List<String>.from(savedAnswer);
          } else if (savedAnswer is Map) {
            initialAnswers =
                (savedAnswer as Map).values.cast<String>().toList();
          }
        }

        return MultipleChoiceQuestion(
          question: question,
          initialAnswers: initialAnswers,
          onAnswer: (answers) {
            _safeStateUpdate(() => saveAnswer(questionId, answers));
          },
          onValidityChanged: (isValid) {
            _safeStateUpdate(() {
              setState(() => isCurrentQuestionValid = isValid);
            });
          },
        );
      case 'grouped_single_choice':
        return GroupedSingleChoiceQuestion(
          question: question,
          initialAnswers: savedAnswer as Map<String, String>?,
          onAnswer: (answers) {
            _safeStateUpdate(() => saveAnswer(questionId, answers));
          },
          onValidityChanged: (isValid) {
            _safeStateUpdate(() {
              setState(() => isCurrentQuestionValid = isValid);
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Helper method to safely update state
  void _safeStateUpdate(VoidCallback callback) {
    if (_isBuilding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) callback();
      });
    } else {
      callback();
    }
  }
}
