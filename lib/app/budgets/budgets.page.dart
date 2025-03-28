import 'package:flutter/material.dart';
import 'package:parsa/app/budgets/budget_form.page.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/presentation/widgets/no_results.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/i18n/translations.g.dart';

import 'components/budget_card.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.budgets.title),
      ),
      floatingActionButton: FloatingActionButton.extended(
          heroTag: UniqueKey(),
          icon: const Icon(Icons.add_rounded),
          label: Text(t.budgets.form.create),
          onPressed: () => RouteUtils.pushRoute(
                context,
                const BudgetFormPage(prevPage: BudgetsPage()),
              )),
      body: StreamBuilder(
          stream: BudgetServive.instance.getBudgets(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Column(
                children: [LinearProgressIndicator()],
              );
            }

            final budgets = snapshot.data!;

            if (budgets.isEmpty) {
              return Column(
                children: [
                  Expanded(
                      child: NoResults(
                          title: t.general.empty_warn,
                          description: t.budgets.no_budgets)),
                ],
              );
            }

            return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (context, index) {
                  final budget = budgets[index];

                  return BudgetCard(budget: budget);
                },
                separatorBuilder: (context, index) {
                  return const SizedBox.shrink();
                },
                itemCount: budgets.length);
          }),
    );
  }
}
