import 'package:flutter/material.dart';
import 'package:parsa/core/models/category/category.dart';
import 'package:parsa/core/utils/uncategorized_utils.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:drift/drift.dart' as drift;
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/app/categories/selectors/category_picker.dart';
import 'package:parsa/core/api/post_methods/post_user_cousin_rules.dart';
import 'package:parsa/core/presentation/audio/app_sound_player.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/models/transaction/transaction_type.enum.dart';
import 'package:parsa/core/extensions/color.extensions.dart';

class UncategorizedClassificationOverlay extends StatefulWidget {
  const UncategorizedClassificationOverlay({Key? key}) : super(key: key);

  @override
  State<UncategorizedClassificationOverlay> createState() =>
      _UncategorizedClassificationOverlayState();
}

class _UncategorizedClassificationOverlayState
    extends State<UncategorizedClassificationOverlay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: const Color(0xB20F1728), // Dimmed background
        child: Center(
          child: GestureDetector(
            onTap:
                () {}, // Prevent tap events from propagating to the background
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.85,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
              decoration: ShapeDecoration(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x07101828),
                    blurRadius: 8,
                    offset: Offset(0, 8),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: Color(0x14101828),
                    blurRadius: 24,
                    offset: Offset(0, 20),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: _UncategorizedClassificationContent(),
            ),
          ),
        ),
      ),
    );
  }
}

class _UncategorizedClassificationContent extends StatefulWidget {
  @override
  State<_UncategorizedClassificationContent> createState() =>
      _UncategorizedClassificationContentState();
}

class _UncategorizedClassificationContentState
    extends State<_UncategorizedClassificationContent> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TransactionGroupByType>>(
      future: _getTop10Groups(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final groups = snapshot.data!;
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

        // --- Summary Card Logic ---
        // Helper to clean up the title
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
            cleaned = cleaned.replaceAll(
                RegExp('\\b$word\\b', caseSensitive: false), '');
          }
          cleaned = cleaned
              .replaceAll(RegExp('[^a-zA-Z0-9áéíóúãõâêîôûçÁÉÍÓÚÃÕÂÊÎÔÛÇ ]'), '')
              .trim();
          if (cleaned.isEmpty) return 'NA';
          return cleaned;
        }

        // Get the first non-empty, non-generic title from the first group's transactions
        String summaryTitle = 'NA';
        if (groups.isNotEmpty) {
          for (final tx in groups.first.transactions) {
            final cleaned = cleanTitle(tx.title);
            if (cleaned != 'NA') {
              summaryTitle = cleaned;
              break;
            }
          }
        }

        // Calculate totals
        final totalAmount =
            groups.fold<double>(0.0, (sum, g) => sum + g.totalValue);
        final totalTransactions =
            groups.fold<int>(0, (sum, g) => sum + g.count);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Summary Card ---
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        summaryTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text('Total',
                                  style: Theme.of(context).textTheme.bodySmall),
                              Text(
                                totalAmount.abs().toStringAsFixed(2),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Transações',
                                  style: Theme.of(context).textTheme.bodySmall),
                              Text(
                                totalTransactions.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // --- CardSwiper ---
              CardSwiper(
                cardsCount: groups.length,
                cardBuilder: (context, index, percentX, percentY) {
                  final group = groups[index];
                  return _LabeledTransactionGroupCard(group: group);
                },
                numberOfCardsDisplayed: 3,
                onSwipe: (prev, curr, direction) async {
                  await AppSoundPlayer.playSwipeSound();
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
                        await AppSoundPlayer.playSuccessSound();
                      } catch (e) {
                        print('Failed to update cousin rules: $e');
                      }
                      setState(() {
                        groups.removeAt(prev);
                      });
                    }
                  }
                  return true;
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<TransactionGroupByType>> _getTop10Groups() async {
    final summaries = await getUncategorizedGroupSummaries();
    final top10 = List<Map<String, dynamic>>.from(summaries)
      ..sort((a, b) =>
          (b['TotalAmount'] as num).compareTo(a['TotalAmount'] as num));
    final displayList = top10.take(10).toList();
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

class _LabeledTransactionGroupCard extends StatelessWidget {
  final TransactionGroupByType group;
  const _LabeledTransactionGroupCard({Key? key, required this.group})
      : super(key: key);

  // Helper to clean up the title (same as in overlay content)
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
    if (cleaned.isEmpty) return 'NA';
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = group.type == CategoryType.I;
    final amountColor = isIncome ? Colors.green : Colors.red;
    // Get the first non-empty, non-generic title from the group's transactions
    String displayTitle = 'NA';
    for (final tx in group.transactions) {
      final cleaned = cleanTitle(tx.title);
      if (cleaned != 'NA') {
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
            Expanded(
              flex: 2,
              child: Text(
                displayTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                height: 88.0 * 4, // Fixed height for 4 transactions
                child: TransactionListComponent(
                  heroTagBuilder: (tr) => 'class-page__tr-icon-${tr.id}',
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
                  prevPage: const UncategorizedClassificationOverlay(),
                  onEmptyList: const Text('Nenhuma transação encontrada'),
                ),
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
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
