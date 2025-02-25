import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/app_colors.dart';

/// Shared styles for all question types in the intake form

// Continue button used across all question types
class ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const ContinueButton({
    Key? key,
    required this.onPressed,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor:
              isEnabled ? appColors.brandDark : Colors.grey.shade200,
          foregroundColor: isEnabled ? Colors.white : Colors.grey.shade500,
          elevation: isEnabled ? 4 : 0,
          shadowColor: isEnabled
              ? appColors.brandDark.withOpacity(0.5)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: isEnabled ? onPressed : null,
        child: const Text(
          'Continuar',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            fontFamily: 'Nunito',
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// Consistent question title styling
TextStyle questionTitleStyle(BuildContext context) {
  return TextStyle(
    color: const Color(0xFF25282B),
    fontWeight: FontWeight.w900,
    fontSize: MediaQuery.of(context).size.width * 0.055,
    fontFamily: 'Nunito',
    height: 1.2,
  );
}

// Consistent option button styling
Widget buildOptionButton({
  required BuildContext context,
  required Map<String, dynamic> option,
  required VoidCallback onTap,
  required bool isSelected,
}) {
  final appColors = AppColors.of(context);

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? appColors.brandDark
            : appColors.brandLight.withAlpha(51),
        foregroundColor: isSelected ? Colors.white : appColors.brandDark,
        minimumSize: const Size.fromHeight(64),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? appColors.brandDark : appColors.brandLight,
            width: 1.5,
          ),
        ),
        elevation: isSelected ? 2 : 0,
        shadowColor:
            isSelected ? appColors.brandDark.withAlpha(51) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              option['text'],
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle_rounded,
              size: 24,
            ),
        ],
      ),
    ),
  );
}

// Single Choice Question Widget
class SingleChoiceQuestion extends StatefulWidget {
  final Map<String, dynamic> question;
  final String? initialAnswer;
  final Function(String) onAnswer;

  const SingleChoiceQuestion({
    Key? key,
    required this.question,
    this.initialAnswer,
    required this.onAnswer,
  }) : super(key: key);

  @override
  _SingleChoiceQuestionState createState() => _SingleChoiceQuestionState();
}

class _SingleChoiceQuestionState extends State<SingleChoiceQuestion> {
  String? selectedOptionId;

  @override
  void initState() {
    super.initState();
    if (widget.initialAnswer != null) {
      setState(() {
        selectedOptionId = widget.initialAnswer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question['question'],
          style: const TextStyle(
            color: Color(0xFF25282B),
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Nunito',
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: widget.question['options'].length,
            itemBuilder: (context, index) {
              final option = widget.question['options'][index];
              final isSelected = selectedOptionId == option['id'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedOptionId = option['id'];
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? appColors.brandDark
                        : const Color(0xFFF0F7FF),
                    foregroundColor:
                        isSelected ? Colors.white : appColors.brandDark,
                    minimumSize: const Size.fromHeight(64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? appColors.brandDark
                            : appColors.brandLight.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    elevation: isSelected ? 2 : 0,
                    shadowColor: isSelected
                        ? appColors.brandDark.withOpacity(0.3)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      option['text'],
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ContinueButton(
          isEnabled: selectedOptionId != null,
          onPressed: () {
            if (selectedOptionId != null) {
              widget.onAnswer(selectedOptionId!);
            }
          },
        ),
      ],
    );
  }
}

// Multiple Choice Question Widget
class MultipleChoiceQuestion extends StatefulWidget {
  final Map<String, dynamic> question;
  final List<String>? initialAnswers;
  final Function(List<String>) onAnswer;

  const MultipleChoiceQuestion({
    Key? key,
    required this.question,
    this.initialAnswers,
    required this.onAnswer,
  }) : super(key: key);

  @override
  _MultipleChoiceQuestionState createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  final Set<String> selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialAnswers != null) {
      setState(() {
        selectedAnswers.addAll(widget.initialAnswers!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question['question'],
          style: const TextStyle(
            color: Color(0xFF25282B),
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Nunito',
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: widget.question['options'].length,
            itemBuilder: (context, index) {
              final option = widget.question['options'][index];
              final isSelected = selectedAnswers.contains(option['id']);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (isSelected) {
                        selectedAnswers.remove(option['id']);
                      } else {
                        selectedAnswers.add(option['id']);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? appColors.brandDark
                        : const Color(0xFFF0F7FF),
                    foregroundColor:
                        isSelected ? Colors.white : appColors.brandDark,
                    minimumSize: const Size.fromHeight(64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? appColors.brandDark
                            : appColors.brandLight.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    elevation: isSelected ? 2 : 0,
                    shadowColor: isSelected
                        ? appColors.brandDark.withOpacity(0.3)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      option['text'],
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ContinueButton(
          isEnabled: selectedAnswers.isNotEmpty,
          onPressed: () {
            if (selectedAnswers.isNotEmpty) {
              widget.onAnswer(selectedAnswers.toList());
            }
          },
        ),
      ],
    );
  }
}

// Grouped Single Choice Question Widget
class GroupedSingleChoiceQuestion extends StatefulWidget {
  final Map<String, dynamic> question;
  final Map<String, String>? initialAnswers;
  final Function(Map<String, String>) onAnswer;

  const GroupedSingleChoiceQuestion({
    Key? key,
    required this.question,
    this.initialAnswers,
    required this.onAnswer,
  }) : super(key: key);

  @override
  _GroupedSingleChoiceQuestionState createState() =>
      _GroupedSingleChoiceQuestionState();
}

class _GroupedSingleChoiceQuestionState
    extends State<GroupedSingleChoiceQuestion> {
  final Map<String, String> answers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialAnswers != null) {
      setState(() {
        answers.addAll(widget.initialAnswers!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question['question'],
          style: const TextStyle(
            color: Color(0xFF25282B),
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Nunito',
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: widget.question['subquestions'].length,
            itemBuilder: (context, index) {
              final subquestion = widget.question['subquestions'][index];
              final subId = subquestion['id'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 16),
                    child: Text(
                      subquestion['question'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito',
                        color: appColors.brandDark,
                      ),
                    ),
                  ),
                  ...subquestion['options']
                      .map<Widget>(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                answers[subId] = option['id'];
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: answers[subId] == option['id']
                                  ? appColors.brandDark
                                  : const Color(0xFFF0F7FF),
                              foregroundColor: answers[subId] == option['id']
                                  ? Colors.white
                                  : appColors.brandDark,
                              minimumSize: const Size.fromHeight(64),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: answers[subId] == option['id']
                                      ? appColors.brandDark
                                      : appColors.brandLight.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              elevation: answers[subId] == option['id'] ? 2 : 0,
                              shadowColor: answers[subId] == option['id']
                                  ? appColors.brandDark.withOpacity(0.3)
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                option['text'],
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: answers[subId] == option['id']
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ),
        ContinueButton(
          isEnabled: widget.question['subquestions'].length == answers.length,
          onPressed: () {
            if (widget.question['subquestions'].length == answers.length) {
              widget.onAnswer(answers);
            }
          },
        ),
      ],
    );
  }
}
