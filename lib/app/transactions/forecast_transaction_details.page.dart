import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parsa/app/transactions/label_value_info_table.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart';
import 'package:parsa/core/extensions/color.extensions.dart';
import 'package:parsa/core/models/forecast/forecasted_transaction.dart';
import 'package:parsa/core/models/transaction/transaction_type.enum.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/core/presentation/widgets/forecast/recurrency_type_badge.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/routes/route_utils.dart';

class ForecastTransactionDetailsPage extends StatelessWidget {
  const ForecastTransactionDetailsPage({
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Detalhes da Previsao'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CardWithHeader(
                    title: 'Previsao',
                    body: LabelValueInfoTable(
                      items: [
                        LabelValueInfoItem(
                          label: 'Valor previsto',
                          value: CurrencyDisplayer(
                            amountToConvert: forecast.forecastAmount,
                            integerStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: forecast.type == TransactionType.I
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                        if (forecast.forecastLow != null &&
                            forecast.forecastHigh != null)
                          LabelValueInfoItem(
                            label: 'Faixa de confianca',
                            value: Text(
                              'R\$ ${forecast.forecastLow!.abs().toStringAsFixed(2)} – R\$ ${forecast.forecastHigh!.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                        LabelValueInfoItem(
                          label: 'Tipo',
                          value: RecurrencyTypeBadge(
                            recurrencyType: forecast.recurrencyType,
                          ),
                        ),
                        if (forecast.category != null)
                          LabelValueInfoItem(
                            label: 'Categoria',
                            value: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                forecast.category!.icon.display(
                                  color: ColorHex.get(forecast.category!.color)
                                      .lighten(0.5),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    forecast.category!.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          ColorHex.get(forecast.category!.color)
                                              .lighten(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (forecast.parentCategoryName != null &&
                            forecast.category == null)
                          LabelValueInfoItem(
                            label: 'Categoria',
                            value: Text(
                              forecast.parentCategoryName!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (forecast.account != null)
                          LabelValueInfoItem(
                            label: 'Conta',
                            value: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/png_icons/${forecast.account!.iconId}.png',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    forecast.account!.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        LabelValueInfoItem(
                          label: forecast.forecastDate != null
                              ? 'Data prevista'
                              : 'Mes previsto',
                          value: Text(
                            forecast.forecastDate != null
                                ? DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR')
                                    .format(forecast.forecastDate!)
                                : DateFormat("MMMM 'de' yyyy", 'pt_BR')
                                    .format(forecast.forecastMonth),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Related transactions via cousin
                  if (forecast.cousin != null) ...[
                    const SizedBox(height: 16),
                    CardWithHeader(
                      onHeaderButtonClick: () {
                        RouteUtils.pushRoute(
                          context,
                          TransactionsPage(
                            filters: TransactionFilters(
                              cousinFilter: forecast.cousin,
                            ),
                          ),
                        );
                      },
                      title: 'Transacoes Similares',
                      body: TransactionListComponent(
                        filters: TransactionFilters(
                          cousinFilter: forecast.cousin,
                        ),
                        prevPage: prevPage,
                        limit: 5,
                        heroTagBuilder: (tr) =>
                            'forecast-related-${tr.id}-${forecast.cousin}',
                        onEmptyList: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Nenhuma transacao similar encontrada',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          Hero(
            tag: heroTag ?? UniqueKey(),
            child: forecast.getDisplayIcon(context, size: 48, padding: 12),
          ),
          const SizedBox(height: 12),
          Text(
            forecast.displayName(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CurrencyDisplayer(
            amountToConvert: forecast.forecastAmount,
            integerStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: forecast.type == TransactionType.I
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          if (forecast.forecastLow != null && forecast.forecastHigh != null) ...[
            const SizedBox(height: 4),
            Text(
              'R\$ ${forecast.forecastLow!.abs().toStringAsFixed(2)} – R\$ ${forecast.forecastHigh!.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
          const SizedBox(height: 8),
          RecurrencyTypeBadge(recurrencyType: forecast.recurrencyType),
        ],
      ),
    );
  }
}
