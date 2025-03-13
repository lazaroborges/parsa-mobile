import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parsa/app/budgets/budget_form_page.dart';
import 'package:parsa/app/budgets/budgets_page.dart';
import 'package:parsa/app/budgets/components/budget_evolution_chart.dart';
import 'package:parsa/app/stats/stats_page.dart';
import 'package:parsa/app/stats/widgets/movements_distribution/chart_by_categories.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/models/budget/budget.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/core/presentation/widgets/confirm_dialog.dart';
import 'package:parsa/core/presentation/widgets/monekin_popup_menu_button.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/core/utils/list_tile_action_item.dart';
import 'package:parsa/i18n/translations.g.dart';

import '../../core/presentation/widgets/no_results.dart';
import 'components/budget_card.dart';

class BudgetDetailsPage extends StatefulWidget {
  const BudgetDetailsPage({super.key, required this.budget});

  final Budget budget;

  @override
  State<BudgetDetailsPage> createState() => _BudgetDetailsPageState();
}

class _BudgetDetailsPageState extends State<BudgetDetailsPage> {
  double? budgetCurrentValue;
  double? budgetCurrentPercentage;

  List<StreamSubscription<double>> subscrList = [];

  @override
  void initState() {
    super.initState();

    subscrList.addAll([
      widget.budget.currentValue.asBroadcastStream().listen((event) {
        setState(() {
          budgetCurrentValue = event;
        });
      }),
      widget.budget.percentageAlreadyUsed.asBroadcastStream().listen((event) {
        setState(() {
          budgetCurrentPercentage = event;
        });
      })
    ]);
  }

  @override
  void dispose() {
    for (final element in subscrList) {
      element.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return StreamBuilder(
        stream: BudgetServive.instance.getBudgetById(widget.budget.id),
        initialData: widget.budget,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();

          final budget = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text(t.budgets.details.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: t.budgets.form.edit,
                  onPressed: () {
                    RouteUtils.pushRoute(
                      context,
                      BudgetFormPage(
                          prevPage: const BudgetsPage(), budgetToEdit: budget),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: t.general.delete,
                  onPressed: () {
                    confirmDialog(
                      context,
                      dialogTitle: t.budgets.delete,
                      contentParagraphs: [Text(t.budgets.delete_warning)],
                      confirmationText: t.general.confirm,
                      icon: Icons.delete,
                    ).then((confirmed) {
                      if (confirmed != true) return;

                      BudgetServive.instance
                          .deleteBudget(budget.id)
                          .then((value) {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(t.budgets.delete),
                        ));
                      }).catchError((err) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('$err')));
                      });
                    });
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: BudgetCard(
                      budget: budget,
                      isHeader: true,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CardWithHeader(
                          title: t.stats.by_categories,
                          body: ChartByCategories(
                            filters: budget.trFilters,
                            datePeriodState: budget.periodState,
                          ),
                          onHeaderButtonClick: () {
                            RouteUtils.pushRoute(
                              context,
                              StatsPage(
                                initialIndex: 1,
                                filters: budget.trFilters,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        CardWithHeader(
                          title: t.home.last_transactions,
                          onHeaderButtonClick: () {
                            RouteUtils.pushRoute(
                              context,
                              TransactionsPage(
                                filters: budget.trFilters,
                              ),
                            );
                          },
                          body: TransactionListComponent(
                            heroTagBuilder: (tr) =>
                                'budgets-page__tr-icon-${tr.id}',
                            filters: budget.trFilters,
                            limit: 5,
                            showGroupDivider: false,
                            prevPage: BudgetDetailsPage(budget: budget),
                            onEmptyList: NoResults(
                                title: t.general.empty_warn,
                                description: t.budgets.details.no_transactions),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CardWithHeader(
                            title: t.budgets.details.expend_evolution,
                            body: BudgetEvolutionChart(budget: budget)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
