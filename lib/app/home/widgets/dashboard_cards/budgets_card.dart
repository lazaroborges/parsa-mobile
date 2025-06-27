import 'package:flutter/material.dart';
import 'package:parsa/app/budgets/components/budget_list_card.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';

class BudgetsCard extends StatelessWidget {
  const BudgetsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: StreamBuilder(
        stream: BudgetService.instance.getBudgets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          }
          final budgets = snapshot.data!;
          return BudgetListCard(
            budgets: budgets,
            limit: 3,
          );
        },
      ),
    );
  }
}
