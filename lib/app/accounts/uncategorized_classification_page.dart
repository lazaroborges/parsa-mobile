import 'package:flutter/material.dart';
import 'package:parsa/app/categories/selectors/category_picker.dart';
import 'package:parsa/core/models/category/category.dart';
import 'package:parsa/core/utils/uncategorized_utils.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:drift/drift.dart' as drift;
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/core/api/post_methods/post_user_cousin_rules.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/core/models/transaction/transaction_type.enum.dart';
import 'package:parsa/core/extensions/color.extensions.dart';
import 'package:parsa/core/presentation/audio/app_sound_player.dart';

class UncategorizedClassificationPage extends StatefulWidget {
  const UncategorizedClassificationPage({Key? key}) : super(key: key);

  @override
  State<UncategorizedClassificationPage> createState() =>
      _UncategorizedClassificationPageState();
}

class _UncategorizedClassificationPageState
    extends State<UncategorizedClassificationPage> {
  List<TransactionGroupByType>? _groups; // State variable for card data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reclassificar Transações'),
      ),
      body: FutureBuilder<List<TransactionGroupByType>>(
        future: _getTop10Groups(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // Only assign once, so CardSwiper can mutate it
          _groups ??= List.from(snapshot.data!);

          final groups = _groups!;
          if (groups.isEmpty) {
            return const Center(
                child: Text('Nenhuma transação não categorizada.'));
          }
          if (groups.length == 1) {
            final group = groups.first;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _LabeledTransactionGroupCard(group: group),
              ),
            );
          }
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.75,
              child: CardSwiper(
                cardsCount: groups.length,
                cardBuilder: (context, index, percentX, percentY) {
                  final group = groups[index];
                  return _LabeledTransactionGroupCard(group: group);
                },
                numberOfCardsDisplayed: 3,
                allowedSwipeDirection: AllowedSwipeDirection.only(
                  left: true,
                  right: true,
                ),
                onSwipe: (prev, curr, direction) async {
                  // await AppSoundPlayer.playSwipeSound();
                  if (direction == CardSwiperDirection.right) {
                    final group = groups[prev];
                    final selectedCategory = await showCategoryPickerModal(
                      context,
                      modal: CategoryPicker(
                        selectedCategory: group.transactions.first.category,
                        categoryType: group.type == CategoryType.I
                            ? [CategoryType.B, CategoryType.I]
                            : [CategoryType.E, CategoryType.B],
                      ),
                    );
                    if (selectedCategory != null) {
                      await Future.wait(group.transactions.map((tx) =>
                          TransactionService.instance.insertOrUpdateTransaction(
                            tx.copyWith(
                                categoryID: drift.Value(selectedCategory.id)),
                            null,
                            1,
                          )));
                      final triggeringId =
                          group.transactions.first.id.toString();
                      final cousinValue = group.cousin;
                      final changes = {
                        'categoryName': selectedCategory.name,
                        'categoryId': selectedCategory.id,
                      };
                      try {
                        await PostUserCousinRules.updateCousinRules(
                          cousinValue: cousinValue,
                          triggeringId: triggeringId,
                          changes: changes,
                          applyToFuture: true,
                        );
                        // await AppSoundPlayer.playSuccessSound();
                      } catch (e) {
                        print('Failed to update cousin rules: $e');
                      }
                    }
                  }
                  return true;
                },
                onEnd: () {
                  // Show loading dialog, then after a short delay, show continue dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(height: 24),
                          CircularProgressIndicator(),
                          SizedBox(height: 24),
                          Text(
                            'Carregando Relatório',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.of(context, rootNavigator: true).pop();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              'Relatório pronto!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const _PlaceholderNextPage(),
                                  ),
                                );
                              },
                              child: const Text('Continuar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<TransactionGroupByType>> _getTop10Groups() async {
    final summaries = await getUncategorizedGroupSummaries();
    // Sort and take top 10
    final top10 = List<Map<String, dynamic>>.from(summaries)
      ..sort((a, b) =>
          (b['TotalAmount'] as num).compareTo(a['TotalAmount'] as num));
    final displayList = top10.take(10).toList();
    // For each, fetch the full group
    List<TransactionGroupByType> result = [];
    for (final summary in displayList) {
      final cousin = summary['cousin_id'] as int;
      final type =
          summary['type'] == 'income' ? CategoryType.I : CategoryType.E;
      final txs =
          await getUncategorizedTransactionsForCousinAndType(cousin, type);
      if (txs.isNotEmpty) {
        result.add(TransactionGroupByType(
          cousin: cousin,
          type: type,
          transactions: txs,
        ));
      }
    }
    return result;
  }
}

/// Card with a label for income/expense type and group summary
class _LabeledTransactionGroupCard extends StatelessWidget {
  final TransactionGroupByType group;
  const _LabeledTransactionGroupCard({Key? key, required this.group})
      : super(key: key);

  // Helper to clean up the title (copied from overlay for consistency)
  String cleanTitle(String? title) {
    if (title == null || title.trim().isEmpty) return 'NA';
    final genericWords = [
      'Transferencia',
      'Transferência',
      'Pix',
      'de',
      'para',
      'TED',
      'DOC',
      'Pagamento',
      'Fatura',
      'Bancária',
      'Recebida',
      'Recebido',
      'Enviada',
      'Enviado',
      'Outros',
      'Pagamento',
      'Cartão',
      'Fatura',
      'Boleto',
      'Crédito',
      'Débito',
      'Conta',
      'Banco',
      'Saldo',
      'NA',
      'Não Classificada',
      'Despesa',
      'Receita'
    ];
    String cleaned = title;
    for (final word in genericWords) {
      cleaned =
          cleaned.replaceAll(RegExp('\\b$word\\b', caseSensitive: false), '');
    }
    cleaned = cleaned
        .replaceAll(RegExp('[^a-zA-Z0-9áéíóúãõâêîôûçÁÉÍÓÚÃÕÂÊÎÔÛÇ ]'), '')
        .trim();
    if (cleaned.isEmpty) return 'Não identificado';
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = group.type == CategoryType.I;
    final amountColor = isIncome ? Colors.green : Colors.red;
    // Get the first non-empty, non-generic title from the group's transactions
    String displayTitle = 'Não identificado';
    for (final tx in group.transactions) {
      final cleaned = cleanTitle(tx.title);
      if (cleaned != 'NA' && cleaned != 'Não identificado') {
        displayTitle = cleaned;
        break;
      }
    }
    // Format amount as currency string (no CurrencyDisplayer)
    String formatCurrency(double value) {
      return 'R\$ ' + value.abs().toStringAsFixed(2).replaceAll('.', ',');
    }

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  displayTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('Transações', style: TextStyle(fontSize: 10)),
                      Text(
                        group.count.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: amountColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 10)),
                      Text(
                        formatCurrency(group.totalValue),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // --- CardWithHeader: Transaction List ---
            CardWithHeader(
              title: 'Transações deste grupo',
              bodyPadding: EdgeInsets.zero,
              body: SizedBox(
                height: 78.0 * 4, // Fixed height for 4 transactions
                child: TransactionListComponent(
                  heroTagBuilder: (tr) => 'class-page__tr-icon-${tr.id}',
                  filters: TransactionFilters(
                    cousinFilter: group.cousin,
                    status: [
                      TransactionStatus.pending,
                      TransactionStatus.reconciled,
                      TransactionStatus.unreconciled,
                      TransactionStatus.voided,
                    ],
                    transactionTypes: [
                      group.type == CategoryType.I
                          ? TransactionType.I
                          : TransactionType.E
                    ],
                  ),
                  limit: 4,
                  accountNameMaxLength: 10,
                  showGroupDivider: false,
                  showDate: true,
                  prevPage: const UncategorizedClassificationPage(),
                  onEmptyList: const Text('Nenhuma transação encontrada'),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // --- See All Button ---
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TransactionsPage(
                        filters: TransactionFilters(
                          cousinFilter: group.cousin,
                          transactionTypes: [
                            group.type == CategoryType.I
                                ? TransactionType.I
                                : TransactionType.E
                          ],
                          status: [
                            TransactionStatus.pending,
                            TransactionStatus.reconciled,
                            TransactionStatus.unreconciled,
                            TransactionStatus.voided,
                          ],
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('Ver todas as transações'),
              ),
            ),
            const SizedBox(height: 4),
            // --- Instructions Box ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swipe,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Deslize para direita para reclassificar\nDeslize para esquerda para descartar',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderNextPage extends StatelessWidget {
  const _PlaceholderNextPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Próxima Página')),
      body: const Center(child: Text('Conteúdo futuro aqui.')),
    );
  }
}
