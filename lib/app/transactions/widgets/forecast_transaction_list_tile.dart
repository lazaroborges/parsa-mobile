import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:parsa/app/transactions/forecast_transaction_details.page.dart';
import 'package:parsa/core/models/forecast/forecasted_transaction.dart';
import 'package:parsa/core/presentation/widgets/forecast/recurrency_type_badge.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/core/routes/route_utils.dart';

import '../../../core/models/transaction/transaction_type.enum.dart';

class ForecastTransactionListTile extends StatelessWidget {
  const ForecastTransactionListTile({
    super.key,
    required this.forecast,
    required this.prevPage,
    this.heroTag,
  });

  final ForecastedTransaction forecast;
  final Widget prevPage;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);

    return ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    forecast.displayName(),
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
                const SizedBox(width: 6),
                RecurrencyTypeBadge(
                  recurrencyType: forecast.recurrencyType,
                  small: true,
                ),
              ],
            ),
          ),
          CurrencyDisplayer(
            amountToConvert: forecast.forecastAmount,
            integerStyle: TextStyle(
              color: forecast.type == TransactionType.I
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      subtitle: DefaultTextStyle(
        style: Theme.of(context)
            .textTheme
            .labelSmall!
            .copyWith(fontWeight: FontWeight.w300),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${forecast.account?.name ?? ''} • ${DateFormat("MMMM yyyy", 'pt_BR').format(forecast.forecastMonth)}',
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
            if (forecast.confidenceBandText != null)
              Text(
                forecast.confidenceBandText!,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
          ],
        ),
      ),
      leading: Hero(
        tag: heroTag ?? UniqueKey(),
        child: forecast.getDisplayIcon(context, size: 28, padding: 6),
      ),
      onTap: () {
        RouteUtils.pushRoute(
          context,
          ForecastTransactionDetailsPage(
            forecast: forecast,
            prevPage: prevPage,
            heroTag: heroTag,
          ),
        );
      },
    );
  }
}
