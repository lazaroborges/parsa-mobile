import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:parsa/core/presentation/app_colors.dart';

class IntakeForm extends StatefulWidget {
  const IntakeForm({Key? key}) : super(key: key);

  @override
  _IntakeFormState createState() => _IntakeFormState();
}

class _IntakeFormState extends State<IntakeForm> {
  List<dynamic>? questions;
  int currentQuestionIndex = 0;
  Map<String, dynamic> answers = {};
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> loadQuestions() async {
    try {
      String jsonString = await DefaultAssetBundle.of(context)
          .loadString('lib/app/onboarding/questions.json');
      setState(() {
        questions = json.decode(jsonString)['questions'];
      });
    } catch (e) {
      print('Error loading questions: $e');
      // Handle error appropriately
    }
  }

  double get progress {
    if (questions == null) return 0.0;
    return (currentQuestionIndex + 1) / questions!.length;
  }

  Future<void> saveAnswer(String questionId, dynamic answer) async {
    answers[questionId] = answer;
    await prefs.setString('intake_answers', json.encode(answers));
  }

  @override
  Widget buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.of(context).brandLight.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.of(context).brandDark,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            'Questão ${currentQuestionIndex + 1} de ${questions!.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.of(context).brandDark,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget buildQuestion(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'single_choice':
        return SingleChoiceQuestion(
          question: question,
          onAnswer: (answer) {
            saveAnswer(question['id'], answer);
            moveToNextQuestion();
          },
        );
      case 'multiple_choice':
        return MultipleChoiceQuestion(
          question: question,
          onAnswer: (answers) {
            saveAnswer(question['id'], answers);
            moveToNextQuestion();
          },
        );
      case 'grouped_single_choice':
        return GroupedSingleChoiceQuestion(
          question: question,
          onAnswer: (answers) {
            saveAnswer(question['id'], answers);
            moveToNextQuestion();
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < questions!.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Navigate to next screen after completing all questions
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.of(context).brandDark,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            buildProgressBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: buildQuestion(questions![currentQuestionIndex]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Question type widgets
class SingleChoiceQuestion extends StatelessWidget {
  final Map<String, dynamic> question;
  final Function(String) onAnswer;

  const SingleChoiceQuestion({
    Key? key,
    required this.question,
    required this.onAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: appColors.brandDark,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nunito',
              ),
        ),
        const SizedBox(height: 24),
        ...question['options']
            .map<Widget>(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionButton(
                  context: context,
                  option: option,
                  onTap: () => onAnswer(option['id']),
                  isSelected: false,
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}

Widget _buildOptionButton({
  required BuildContext context,
  required Map<String, dynamic> option,
  required VoidCallback onTap,
  required bool isSelected,
}) {
  final appColors = AppColors.of(context);

  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: isSelected
          ? appColors.brandDark
          : appColors.brandLight.withOpacity(0.1),
      foregroundColor: isSelected ? Colors.white : appColors.brandDark,
      minimumSize: const Size.fromHeight(64),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? appColors.brandDark : appColors.brandLight,
          width: 1.5,
        ),
      ),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            option['text'],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Nunito',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ),
        if (isSelected)
          Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 24,
          ),
      ],
    ),
  );
}

class MultipleChoiceQuestion extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function(List<String>) onAnswer;

  const MultipleChoiceQuestion({
    Key? key,
    required this.question,
    required this.onAnswer,
  }) : super(key: key);

  @override
  _MultipleChoiceQuestionState createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  final Set<String> selectedAnswers = {};

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question['question'],
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: appColors.brandDark,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        ...widget.question['options']
            .map<Widget>(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (selectedAnswers.contains(option['id'])) {
                        selectedAnswers.remove(option['id']);
                      } else {
                        selectedAnswers.add(option['id']);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAnswers.contains(option['id'])
                        ? appColors.brand
                        : appColors.brand.withAlpha(10),
                    foregroundColor: selectedAnswers.contains(option['id'])
                        ? Colors.white
                        : appColors.brandDark,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: appColors.brand,
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option['text'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (selectedAnswers.contains(option['id']))
                        const Icon(Icons.check, size: 20),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: selectedAnswers.isNotEmpty
              ? () => widget.onAnswer(selectedAnswers.toList())
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: appColors.brandDark,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            disabledBackgroundColor: appColors.brandLight,
          ),
          child: const Text(
            'Continuar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class GroupedSingleChoiceQuestion extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function(Map<String, String>) onAnswer;

  const GroupedSingleChoiceQuestion({
    Key? key,
    required this.question,
    required this.onAnswer,
  }) : super(key: key);

  @override
  _GroupedSingleChoiceQuestionState createState() =>
      _GroupedSingleChoiceQuestionState();
}

class _GroupedSingleChoiceQuestionState
    extends State<GroupedSingleChoiceQuestion> {
  final Map<String, String> answers = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question['question'],
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: appColors.brandDark,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.question['subquestions']
                  .map<Widget>(
                    (subquestion) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subquestion['question'],
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: appColors.brandDark,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        ...subquestion['options']
                            .map<Widget>(
                              (option) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      answers[subquestion['id']] = option['id'];
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        answers[subquestion['id']] ==
                                                option['id']
                                            ? appColors.brand
                                            : appColors.brand.withAlpha(10),
                                    foregroundColor:
                                        answers[subquestion['id']] ==
                                                option['id']
                                            ? Colors.white
                                            : appColors.brandDark,
                                    minimumSize: const Size.fromHeight(56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: appColors.brand,
                                        width: 1,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        option['text'],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      if (answers[subquestion['id']] ==
                                          option['id'])
                                        const Icon(Icons.check, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              onPressed:
                  answers.length == widget.question['subquestions'].length
                      ? () => widget.onAnswer(answers)
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.brandDark,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                disabledBackgroundColor: appColors.brandLight,
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
