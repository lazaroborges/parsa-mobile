// ignore_for_file: unnecessary_string_interpolations, prefer_single_quotes

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/app/stats/widgets/movements_distribution/category_stats_modal.dart';
import 'package:parsa/app/transactions/form/transaction_form.page.dart';
import 'package:parsa/app/transactions/widgets/bulk_edit_transaction_modal.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/models/category/category.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/widgets/confirm_dialog.dart';
import 'package:parsa/core/presentation/widgets/filter_row_indicator.dart';
import 'package:parsa/core/presentation/widgets/monekin_popup_menu_button.dart';
import 'package:parsa/core/presentation/widgets/no_results.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/core/presentation/widgets/skeleton.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/filter_sheet_modal.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/app/stats/widgets/movements_distribution/chart_by_categories.dart';
import 'package:parsa/core/database/services/forecast/forecast_mode_service.dart';
import 'package:parsa/core/database/services/forecast/forecast_transaction_service.dart';
import 'package:parsa/core/presentation/widgets/forecast/forecast_empty_state.dart';

enum SortMode { date, valueAsc, valueDesc }

TransactionQueryOrderBy amountAscOrderBy =
    (t, a, ac, ra, rac, c, sc) => OrderBy([OrderingTerm.asc(t.value)]);
TransactionQueryOrderBy amountDescOrderBy =
    (t, a, ac, ra, rac, c, sc) => OrderBy([OrderingTerm.desc(t.value)]);

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({
    super.key,
    this.filters,
    this.categoryStatsData,
    this.dateRangeText,
  });

  final TransactionFilters? filters;
  final TrDistributionChartItem<Category>? categoryStatsData;
  final String? dateRangeText;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late TransactionFilters filters;
  bool isAllFilteredSelected = false;

  bool searchActive = false;
  FocusNode searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  List<MoneyTransaction> selectedTransactions = [];

  SortMode _sortMode = SortMode.date;

  @override
  void initState() {
    super.initState();

    filters = widget.filters ?? const TransactionFilters();

    searchFocusNode.addListener(() {
      if (!searchFocusNode.hasFocus && searchController.text.isEmpty) {
        setState(() {
          searchActive = false;
        });
      }
    });

    // Show the modal if we have category stats data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryStatsData != null && widget.dateRangeText != null) {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (context) => CategoryStatsModal(
            categoryData: widget.categoryStatsData!,
            filters: filters,
            dateRangeText: widget.dateRangeText!,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _toggleSortOrder() {
    setState(() {
      switch (_sortMode) {
        case SortMode.date:
          _sortMode = SortMode.valueDesc;
          break;
        case SortMode.valueDesc:
          _sortMode = SortMode.valueAsc;
          break;
        case SortMode.valueAsc:
          _sortMode = SortMode.date;
          break;
      }
    });
  }

  TransactionQueryOrderBy? _getOrderBy() {
    switch (_sortMode) {
      case SortMode.valueAsc:
        return amountAscOrderBy;
      case SortMode.valueDesc:
        return amountDescOrderBy;
      case SortMode.date:
      default:
        return null;
    }
  }

  Widget _buildSortIcon() {
    switch (_sortMode) {
      case SortMode.valueDesc:
        return const Icon(Icons.arrow_downward);
      case SortMode.valueAsc:
        return const Icon(Icons.arrow_upward);
      case SortMode.date:
      default:
        return const Icon(Icons.sort);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return StreamBuilder<bool>(
      stream: ForecastModeService.instance.forecastModeStream,
      initialData: ForecastModeService.instance.isInForecastMode,
      builder: (context, forecastSnapshot) {
        final isForecastMode = forecastSnapshot.data ?? false;

        if (isForecastMode) {
          return _buildForecastView(context, t);
        }
        return _buildRealView(context, t);
      },
    );
  }

  Widget _buildForecastView(BuildContext context, Translations t) {
    final searchText =
        searchController.text.isNotEmpty ? searchController.text : null;

    return StreamBuilder<ForecastCountResult>(
      stream: ForecastTransactionService.instance.countForecasts(
        searchValue: searchText,
        minDate: filters.minDate,
        maxDate: filters.maxDate,
        transactionTypes: filters.transactionTypes,
        accountsIDs: filters.accountsIDs,
        categories: filters.categories,
        includeParentCategoriesInSearch: filters.includeParentCategoriesInSearch,
      ),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: searchActive
                ? TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    decoration: InputDecoration(
                      hintText: t.transaction.list.searcher_placeholder,
                      border: const UnderlineInputBorder(),
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  )
                : const Text('Previsoes'),
            leading: searchActive
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        searchActive = false;
                        searchController.text = "";
                      });
                    },
                    icon: const Icon(Icons.close))
                : null,
            actions: [
              if (!searchActive)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchActive = true;
                    });
                    searchFocusNode.requestFocus();
                  },
                ),
              IconButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final lastDayOfMonth =
                      DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                  final preselected = filters.copyWith(
                    maxDate: filters.maxDate ?? lastDayOfMonth,
                  );
                  final modalRes = await openFilterSheetModal(
                    context,
                    FilterSheetModal(preselectedFilter: preselected),
                  );

                  if (modalRes != null) {
                    setState(() {
                      filters = modalRes;
                    });
                  }
                },
                icon: const Icon(Icons.filter_alt_outlined),
              ),
            ],
          ),
          // No FAB in forecast mode
          body: Column(
            children: [
              if (filters.hasFilter) ...[
                FilterRowIndicator(
                  filters:
                      filters.copyWith(searchValue: searchController.text),
                  onChange: (newFilters) {
                    setState(() {
                      filters = newFilters;
                    });
                  },
                ),
              ],
              Card(
                elevation: 2,
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleMedium!,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (snapshot.hasData) ...[
                          Text('${snapshot.data!.numberOfRes} previsoes'),
                          CurrencyDisplayer(
                            amountToConvert: snapshot.data!.valueSum,
                          ),
                        ],
                        if (!snapshot.hasData) ...[
                          const Skeleton(width: 38, height: 18),
                          const Skeleton(width: 28, height: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TransactionListComponent(
                  filters: filters.copyWith(searchValue: searchController.text),
                  transactionsStream:
                      ForecastTransactionService.instance.getTransactions(
                    searchValue: searchText,
                    minDate: filters.minDate,
                    maxDate: filters.maxDate,
                    transactionTypes: filters.transactionTypes,
                    accountsIDs: filters.accountsIDs,
                    categories: filters.categories,
                    includeParentCategoriesInSearch:
                        filters.includeParentCategoriesInSearch,
                  ),
                  heroTagBuilder: (tr) =>
                      'forecast-page__tr-icon-${tr.id}',
                  showGroupDivider: _sortMode == SortMode.date,
                  prevPage: const TabsPage(),
                  onLongPress: (_) {},
                  onEmptyList: const ForecastEmptyState(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealView(BuildContext context, Translations t) {
    return PopScope(
      canPop: !searchActive && selectedTransactions.isEmpty,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (selectedTransactions.isNotEmpty) {
          cleanSelectedTransactions();
          return;
        }

        if (searchFocusNode.hasFocus && searchController.text.isNotEmpty) {
          searchFocusNode.unfocus();
          return;
        } else if (searchActive && !searchFocusNode.hasFocus) {
          setState(() {
            searchActive = false;
            searchController.text = "";
          });

          return;
        }

        Navigator.pop(context);
      },
      child: StreamBuilder(
        stream: TransactionService.instance.countTransactions(
          predicate: filters.copyWith(
            searchValue: searchController.text,
            status: filters.status
                    ?.where((s) => s != TransactionStatus.notconsidered)
                    .toList() ??
                [
                  TransactionStatus.pending,
                  TransactionStatus.reconciled,
                  TransactionStatus.unreconciled,
                  TransactionStatus.voided
                ],
          ),
        ),
        builder: (context, snapshot) {
          final transactionCount = snapshot.data?.numberOfRes ?? 0;
          const smallerTextStyle =
              TextStyle(fontSize: 14, fontWeight: FontWeight.w300);

          return Scaffold(
            appBar: selectedTransactions.isNotEmpty
                ? selectedTransactionsAppbar()
                : AppBar(
                    leading: searchActive
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                searchActive = false;
                                searchController.text = "";
                              });
                            },
                            icon: const Icon(Icons.close))
                        : null,
                    title: searchActive
                        ? TextField(
                            controller: searchController,
                            focusNode: searchFocusNode,
                            decoration: InputDecoration(
                              hintText: t.transaction.list.searcher_placeholder,
                              border: const UnderlineInputBorder(),
                            ),
                            onChanged: (text) {
                              setState(() {});
                            },
                          )
                        : Text(t.transaction.display(n: 10)),
                    actions: [
                      if (transactionCount < 300)
                        IconButton(
                          icon: _buildSortIcon(),
                          onPressed: _toggleSortOrder,
                        ),
                      if (filters.hasFilter || searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            isAllFilteredSelected
                                ? Icons.select_all
                                : Icons.deselect,
                            color: isAllFilteredSelected
                                ? AppColors.of(context).primary
                                : null,
                          ),
                          onPressed: () {
                            setState(() {
                              isAllFilteredSelected = !isAllFilteredSelected;
                              if (isAllFilteredSelected) {
                                TransactionService.instance
                                    .getTransactions(
                                      filters: filters.copyWith(
                                        searchValue: searchController.text,
                                      ),
                                    )
                                    .first
                                    .then((transactions) {
                                  setState(() {
                                    selectedTransactions = transactions;
                                  });
                                });
                              } else {
                                selectedTransactions = [];
                              }
                            });
                          },
                        ),
                      if (!searchActive)
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              searchActive = true;
                            });

                            searchFocusNode.requestFocus();
                          },
                        ),
                      IconButton(
                        onPressed: () async {
                          final modalRes = await openFilterSheetModal(
                            context,
                            FilterSheetModal(preselectedFilter: filters),
                          );

                          if (modalRes != null) {
                            setState(() {
                              filters = modalRes;
                            });
                          }
                        },
                        icon: const Icon(Icons.filter_alt_outlined),
                      ),
                    ],
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => RouteUtils.pushRoute(
                context,
                const TransactionFormPage(),
              ),
              child: const Icon(Icons.add_rounded),
            ),
            body: Column(
              children: [
                if (filters.hasFilter) ...[
                  FilterRowIndicator(
                    filters:
                        filters.copyWith(searchValue: searchController.text),
                    onChange: (newFilters) {
                      setState(() {
                        filters = newFilters;
                      });
                    },
                  ),
                ],
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    child: Column(
                      children: [
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.titleMedium!,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (snapshot.hasData) ...[
                                Text.rich(
                                  TextSpan(
                                      text: selectedTransactions.isNotEmpty
                                          ? ('${selectedTransactions.length.toStringAsFixed(0)}')
                                          : '',
                                      children: [
                                        TextSpan(
                                            text:
                                                '${selectedTransactions.isNotEmpty ? ' / ' : ''}${snapshot.data!.numberOfRes} ',
                                            style:
                                                selectedTransactions.isNotEmpty
                                                    ? smallerTextStyle
                                                    : null),
                                        TextSpan(
                                          text: t.transaction
                                              .display(
                                                  n: snapshot.data!.numberOfRes)
                                              .toLowerCase(),
                                        ),
                                      ]),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (selectedTransactions.isNotEmpty) ...[
                                      CurrencyDisplayer(
                                        amountToConvert: selectedTransactions
                                            .map((e) => e
                                                .getCurrentBalanceInPreferredCurrency())
                                            .sum,
                                        showDecimals: false,
                                      ),
                                      const Text("/ ", style: smallerTextStyle)
                                    ],
                                    CurrencyDisplayer(
                                      amountToConvert: snapshot.data!.valueSum,
                                      showDecimals:
                                          selectedTransactions.isEmpty,
                                      integerStyle: selectedTransactions.isEmpty
                                          ? const TextStyle(inherit: true)
                                          : smallerTextStyle,
                                    ),
                                  ],
                                )
                              ],
                              if (!snapshot.hasData) ...[
                                const Skeleton(width: 38, height: 18),
                                const Skeleton(width: 28, height: 18),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TransactionListComponent(
                    heroTagBuilder: (tr) =>
                        'transactions-page__tr-icon-${tr.id}',
                    filters:
                        filters.copyWith(searchValue: searchController.text),
                    orderBy: _getOrderBy(),
                    showGroupDivider: _sortMode == SortMode.date,
                    prevPage: const TabsPage(),
                    selectedTransactions: selectedTransactions,
                    onLongPress: (tr) {
                      if (selectedTransactions.isNotEmpty) {
                        return;
                      }

                      setState(() {
                        selectedTransactions = [tr];
                      });
                    },
                    onTap:
                        selectedTransactions.isEmpty ? null : toggleTransaction,
                    onEmptyList: NoResults(
                      title: filters.hasFilter ? null : t.general.empty_warn,
                      description: filters.hasFilter
                          ? t.transaction.list.searcher_no_results
                          : t.transaction.list.empty,
                      noSearchResultsVariation: filters.hasFilter,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar selectedTransactionsAppbar() {
    return AppBar(
      backgroundColor: AppColors.of(context).primary,
      foregroundColor: AppColors.of(context).onPrimary,
      leading: IconButton(
        onPressed: () {
          cleanSelectedTransactions();
        },
        icon: const Icon(Icons.close),
      ),
      title: Text(
        t.transaction.list.selected_short(n: selectedTransactions.length),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (context) {
                return BulkEditTransactionModal(
                  transactionsToEdit: selectedTransactions,
                  onSuccess: () {
                    selectedTransactions = [];
                    setState(() {});
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// Clear all the selected transactions (remove the selection)
  void cleanSelectedTransactions() {
    setState(() {
      selectedTransactions = [];
      isAllFilteredSelected = false;
    });
  }

  void toggleTransaction(MoneyTransaction tr) {
    HapticFeedback.lightImpact();

    setState(() {
      if (selectedTransactions.any((element) => element.id == tr.id)) {
        selectedTransactions.removeWhere((element) => element.id == tr.id);
        isAllFilteredSelected = false;
      } else {
        selectedTransactions.add(tr);
      }
    });
  }
}
