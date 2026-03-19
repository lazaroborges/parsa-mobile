import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parsa/app/transactions/widgets/transaction_list_tile.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/models/date-utils/periodicity.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';

import '../../../core/presentation/app_colors.dart';

class TransactionListComponent extends StatefulWidget {
  const TransactionListComponent({
    super.key,
    required this.filters,
    this.showGroupDivider = true,
    this.showDate = false,
    this.periodicityInfo,
    required this.prevPage,
    this.orderBy,
    this.limit = 40,
    this.accountNameMaxLength,
    this.onLoading = const Column(
      children: [
        LinearProgressIndicator(),
      ],
    ),
    required this.onEmptyList,
    required this.heroTagBuilder,
    this.onLongPress,
    this.onTap,
    this.selectedTransactions = const [],
    this.onTransactionsLoaded,
    this.transactionsStream,
  });

  /// Optional external stream of transactions. When provided, this stream is
  /// used instead of querying TransactionService internally. This enables
  /// reuse of this component with forecast data or other data sources.
  final Stream<List<MoneyTransaction>>? transactionsStream;

  final TransactionFilters filters;
  final int? accountNameMaxLength;

  final TransactionQueryOrderBy? orderBy;
  final int limit;

  /// Widget to display while the transactions are loading
  final Widget onLoading;

  /// Widget to display if there are no transactions to display based on the passed params
  final Widget onEmptyList;

  final bool showGroupDivider;

  final bool showDate;

  /// If defined, display info about the periodicity of the recurrent transactions, and the days to the next payment. Will show the amount of the recurrency based on the specified periodicity
  final Periodicity? periodicityInfo;

  final Widget prevPage;

  final Object? Function(MoneyTransaction tr)? heroTagBuilder;

  /// Action to trigger when a transaction tile is long pressed. If `null`,
  /// the tile will display a modal with some quick actions for
  /// this transaction
  final void Function(MoneyTransaction tr)? onLongPress;

  /// Action to trigger when a transaction tile is pressed. If `null`,
  /// the tile will redirect to the `transaction-details-page`
  final void Function(MoneyTransaction tr)? onTap;

  final void Function({List<MoneyTransaction> allTransactions})?
      onTransactionsLoaded;

  final List<MoneyTransaction> selectedTransactions;

  @override
  State<TransactionListComponent> createState() =>
      _TransactionListComponentState();
}

class _TransactionListComponentState extends State<TransactionListComponent> {
  ScrollController listController = ScrollController();

  int currentPage = 1;

  @override
  void initState() {
    super.initState();

    listController.addListener(() {
      if (listController.offset >= listController.position.maxScrollExtent &&
          !listController.position.outOfRange) {
        currentPage += 1;

        setState(() {});
      }
    });
  }

  Widget dateSeparator(BuildContext context, DateTime date) {
    return Container(
      padding: const EdgeInsets.only(right: 12),
      margin: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
        decoration: BoxDecoration(
          color: AppColors.of(context).light,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(120),
            topRight: Radius.circular(120),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMMMMd().format(date)),
            StreamBuilder(
                initialData: 0.0,
                stream: AccountService.instance.getAccountsBalance(
                  filters: widget.filters.copyWith(
                    minDate: DateTime(date.year, date.month, date.day),
                    maxDate: DateTime(date.year, date.month, date.day + 1),
                  ),
                ),
                builder: (context, snapshot) {
                  final partialBalance = snapshot.data!;

                  return CurrencyDisplayer(
                    amountToConvert: partialBalance,
                    integerStyle:
                        Theme.of(context).textTheme.labelMedium!.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                  );
                })
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.transactionsStream ??
        TransactionService.instance.getTransactions(
          filters: widget.filters,
          limit: widget.limit * currentPage,
          orderBy: widget.orderBy,
        );

    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return widget.onLoading;
          }

          final transactions = snapshot.data!;

          if (widget.onTransactionsLoaded != null) {
            widget.onTransactionsLoaded!(allTransactions: transactions);
          }

          if (transactions.isEmpty) {
            return widget.onEmptyList;
          }

          return ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: transactions.length + 1,
              controller: listController,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (transactions.isEmpty) return Container();

                if (index == 0) {
                  if (!widget.showGroupDivider) return Container();
                  return dateSeparator(context, transactions[0].date.toLocal());
                }

                final transaction = transactions[index - 1];

                final heroTag = widget.heroTagBuilder != null
                    ? widget.heroTagBuilder!(transaction)
                    : null;

                return TransactionListTile(
                  transaction: transaction,
                  prevPage: widget.prevPage,
                  periodicityInfo: widget.periodicityInfo,
                  showDate: widget.showDate,
                  showTime: widget.showGroupDivider,
                  heroTag: heroTag,
                  onTap: widget.onTap == null
                      ? null
                      : (() => widget.onTap!(transaction)),
                  onLongPress: widget.onLongPress == null
                      ? null
                      : (() => widget.onLongPress!(transaction)),
                  isSelected: widget.selectedTransactions
                      .any((element) => element.id == transaction.id),
                  accountNameMaxLength: widget.accountNameMaxLength,
                );
              },
              separatorBuilder: (context, index) {
                if (index == 0 ||
                    transactions.isEmpty ||
                    index >= transactions.length) {
                  return Container();
                }

                if (!widget.showGroupDivider ||
                    index >= 1 &&
                        isSameDay(transactions[index - 1].date.toLocal(),
                            transactions[index].date.toLocal())) {
                  // Separator between transactions in the same group
                  return Container();
                }

                // Group separator
                return dateSeparator(context, transactions[index].date.toLocal());
              });
        });
  }
}

// Helper function to check if two dates are the same day
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
