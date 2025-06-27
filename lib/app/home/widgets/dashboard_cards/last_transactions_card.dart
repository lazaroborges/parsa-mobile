import 'package:flutter/material.dart';
import 'package:parsa/app/home/dashboard.page.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/main.dart';

class LastTransactionsCard extends StatelessWidget {
  const LastTransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: CardWithHeader(
        title: t.home.last_transactions,
        onHeaderButtonClick: () {
          tabsPageKey.currentState?.navigateToTab(1);
        },
        body: DashboardTransactionList(
          child: TransactionListComponent(
            heroTagBuilder: (tr) => 'dashboard-page__tr-icon-${tr.id}',
            filters: TransactionFilters(
              status: TransactionStatus.notIn({
                TransactionStatus.pending,
                TransactionStatus.voided,
                TransactionStatus.notconsidered
              }),
            ),
            limit: 5,
            showGroupDivider: false,
            prevPage: const DashboardPage(),
            onEmptyList: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                t.transaction.list.empty,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
