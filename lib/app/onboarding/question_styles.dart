import 'package:flutter/material.dart';

/// Shared styles for all question types in the intake form

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
  return Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              option['text'],
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// Single Choice Question Widget
class SingleChoiceQuestion extends StatefulWidget {
  final Map<String, dynamic> question;
  final String? initialAnswer;
  final Function(String) onAnswer;
  final Function(bool) onValidityChanged;

  const SingleChoiceQuestion({
    Key? key,
    required this.question,
    this.initialAnswer,
    required this.onAnswer,
    required this.onValidityChanged,
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
      widget.onValidityChanged(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            widget.question['question'],
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              fontFamily: 'Nunito',
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: widget.question['options'].length,
            itemBuilder: (context, index) {
              final option = widget.question['options'][index];
              final isSelected = selectedOptionId == option['id'];

              return buildOptionButton(
                context: context,
                option: option,
                onTap: () {
                  setState(() {
                    selectedOptionId = option['id'];
                  });
                  widget.onAnswer(option['id']);
                  widget.onValidityChanged(true);
                },
                isSelected: isSelected,
              );
            },
          ),
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
  final Function(bool) onValidityChanged;

  const MultipleChoiceQuestion({
    Key? key,
    required this.question,
    this.initialAnswers,
    required this.onAnswer,
    required this.onValidityChanged,
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
      widget.onValidityChanged(selectedAnswers.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            widget.question['question'],
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              fontFamily: 'Nunito',
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: widget.question['options'].length,
            itemBuilder: (context, index) {
              final option = widget.question['options'][index];
              final isSelected = selectedAnswers.contains(option['id']);

              return buildOptionButton(
                context: context,
                option: option,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedAnswers.remove(option['id']);
                    } else {
                      selectedAnswers.add(option['id']);
                    }
                  });
                  widget.onAnswer(selectedAnswers.toList());
                  widget.onValidityChanged(selectedAnswers.isNotEmpty);
                },
                isSelected: isSelected,
              );
            },
          ),
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
  final Function(bool) onValidityChanged;

  const GroupedSingleChoiceQuestion({
    Key? key,
    required this.question,
    this.initialAnswers,
    required this.onAnswer,
    required this.onValidityChanged,
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
      widget.onValidityChanged(
          widget.question['subquestions'].length == answers.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            widget.question['question'],
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              fontFamily: 'Nunito',
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: widget.question['subquestions'].length,
            itemBuilder: (context, index) {
              final subquestion = widget.question['subquestions'][index];
              final subId = subquestion['id'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12, top: 16, left: 16),
                    child: Text(
                      subquestion['question'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ...subquestion['options'].map<Widget>(
                    (option) => SizedBox(
                      width: double.infinity,
                      child: buildOptionButton(
                        context: context,
                        option: option,
                        onTap: () {
                          setState(() {
                            answers[subId] = option['id'];
                          });
                          widget.onAnswer(answers);
                          widget.onValidityChanged(
                              widget.question['subquestions'].length ==
                                  answers.length);
                        },
                        isSelected: answers[subId] == option['id'],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
