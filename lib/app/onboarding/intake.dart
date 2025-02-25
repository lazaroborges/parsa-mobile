import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/app/onboarding/question_styles.dart';

class IntakeForm extends StatefulWidget {
  const IntakeForm({Key? key}) : super(key: key);

  @override
  _IntakeFormState createState() => _IntakeFormState();
}

class _IntakeFormState extends State<IntakeForm> with TickerProviderStateMixin {
  List<dynamic>? questions;
  int currentQuestionIndex = 0;
  Map<String, dynamic> answers = {};
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  bool isLoading = true;

  // Animation controllers
  late AnimationController _pageTransitionController;
  late Animation<Offset> _questionSlideInAnimation;

  // Track previous question for animation direction
  int previousQuestionIndex = 0;
  bool get isForwardNavigation => currentQuestionIndex > previousQuestionIndex;

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

    // Slide in from right animation
    _questionSlideInAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
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
    await loadSavedAnswers();
    setState(() {
      isLoading = false;
    });
    // Start with animation completed
    _pageTransitionController.value = 1.0;
  }

  Future<void> loadSavedAnswers() async {
    // Load previously saved answers if they exist
    final savedAnswers = await asyncPrefs.getString('intake_answers');
    if (savedAnswers != null) {
      setState(() {
        answers = json.decode(savedAnswers);
      });
    }
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

  Future<void> saveAnswer(String questionId, dynamic answer) async {
    setState(() {
      answers[questionId] = answer;
    });

    // Save to SharedPreferences asynchronously
    await asyncPrefs.setString('intake_answers', json.encode(answers));
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < questions!.length - 1) {
      setState(() {
        previousQuestionIndex = currentQuestionIndex;
        currentQuestionIndex++;
      });

      // Run the animation
      _pageTransitionController.forward(from: 0.0);
    } else {
      // All questions answered - proceed to next screen
      completeIntakeForm();
    }
  }

  void moveToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        previousQuestionIndex = currentQuestionIndex;
        currentQuestionIndex--;
      });

      // Run the animation
      _pageTransitionController.forward(from: 0.0);
    }
  }

  Future<void> completeIntakeForm() async {
    // Mark intake form as completed with timestamp
    await asyncPrefs.setBool('intake_form_completed', true);
    await asyncPrefs.setString(
        'intake_completion_time', DateTime.now().toIso8601String());

    // Navigate to the next screen
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || questions == null || questions!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Remove app bar space
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildProgressBar(),
            Expanded(
              child: AnimatedBuilder(
                animation: _pageTransitionController,
                builder: (context, child) {
                  // Get the current question data
                  final question = questions![currentQuestionIndex];

                  return SlideTransition(
                    position: _questionSlideInAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: buildQuestion(question),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgressBar() {
    final appColors = AppColors.of(context);
    final totalQuestions = questions?.length ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button - only show when not on first question
          currentQuestionIndex > 0
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: appColors.brandDark,
                  ),
                  onPressed: moveToPreviousQuestion,
                )
              : const SizedBox(width: 40), // Placeholder for alignment

          // Dots indicator
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalQuestions,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: index == currentQuestionIndex ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: index == currentQuestionIndex
                        ? appColors.brandDark
                        : appColors.brandDark.withAlpha(51),
                    boxShadow: index == currentQuestionIndex
                        ? [
                            BoxShadow(
                              color: appColors.brandDark.withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // Empty space on the right to balance the back button
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget buildQuestion(Map<String, dynamic> question) {
    final questionId = question['id'];
    final savedAnswer = answers[questionId];

    switch (question['type']) {
      case 'single_choice':
        return SingleChoiceQuestion(
          question: question,
          initialAnswer: savedAnswer as String?,
          onAnswer: (answer) {
            saveAnswer(questionId, answer);
            moveToNextQuestion();
          },
        );
      case 'multiple_choice':
        return MultipleChoiceQuestion(
          question: question,
          initialAnswers:
              savedAnswer != null ? List<String>.from(savedAnswer) : null,
          onAnswer: (answers) {
            saveAnswer(questionId, answers);
            moveToNextQuestion();
          },
        );
      case 'grouped_single_choice':
        return GroupedSingleChoiceQuestion(
          question: question,
          initialAnswers: savedAnswer != null
              ? Map<String, String>.from(savedAnswer)
              : null,
          onAnswer: (answers) {
            saveAnswer(questionId, answers);
            moveToNextQuestion();
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
