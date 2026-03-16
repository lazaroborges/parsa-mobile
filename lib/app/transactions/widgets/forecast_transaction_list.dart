import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parsa/app/transactions/widgets/forecast_transaction_list_tile.dart';
import 'package:parsa/core/database/services/forecast/forecast_transaction_service.dart';
import 'package:parsa/core/models/forecast/forecasted_transaction.dart';
import 'package:parsa/core/models/transaction/transaction_type.enum.dart';
import 'package:parsa/core/presentation/app_colors.dart';

class ForecastTransactionListComponent extends StatefulWidget {
  const ForecastTransactionListComponent({
    super.key,
    required this.prevPage,
    required this.onEmptyList,
    this.heroTagBuilder,
    this.showGroupDivider = true,
    this.limit = 40,
    this.minDate,
    this.maxDate,
    this.transactionTypes,
    this.accountsIDs,
    this.categories,
    this.searchValue,
    this.cousin,
  });

  final Widget prevPage;
  final Widget onEmptyList;
  final Object? Function(ForecastedTransaction tr)? heroTagBuilder;
  final bool showGroupDivider;
  final int limit;
  final DateTime? minDate;
  final DateTime? maxDate;
  final List<TransactionType>? transactionTypes;
  final Iterable<String>? accountsIDs;
  final Iterable<String>? categories;
  final String? searchValue;
  final int? cousin;

  @override
  State<ForecastTransactionListComponent> createState() =>
      _ForecastTransactionListComponentState();
}

class _ForecastTransactionListComponentState
    extends State<ForecastTransactionListComponent> {
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
        child: Text(DateFormat.yMMMMd().format(date)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ForecastedTransaction>>(
      stream: ForecastTransactionService.instance.getForecasts(
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        transactionTypes: widget.transactionTypes,
        accountsIDs: widget.accountsIDs,
        categories: widget.categories,
        searchValue: widget.searchValue,
        limit: widget.limit * currentPage,
        cousin: widget.cousin,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Column(
            children: [LinearProgressIndicator()],
          );
        }

        final forecasts = snapshot.data!;

        if (forecasts.isEmpty) {
          return widget.onEmptyList;
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: forecasts.length + 1,
          controller: listController,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index == 0) {
              if (!widget.showGroupDivider) return Container();
              return dateSeparator(
                  context, forecasts[0].displayDate.toLocal());
            }

            final forecast = forecasts[index - 1];
            final heroTag = widget.heroTagBuilder != null
                ? widget.heroTagBuilder!(forecast)
                : null;

            return ForecastTransactionListTile(
              forecast: forecast,
              prevPage: widget.prevPage,
              heroTag: heroTag,
            );
          },
          separatorBuilder: (context, index) {
            if (index == 0 ||
                forecasts.isEmpty ||
                index >= forecasts.length) {
              return Container();
            }

            if (!widget.showGroupDivider ||
                index >= 1 &&
                    _isSameDay(forecasts[index - 1].displayDate.toLocal(),
                        forecasts[index].displayDate.toLocal())) {
              return Container();
            }

            return dateSeparator(
                context, forecasts[index].displayDate.toLocal());
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
