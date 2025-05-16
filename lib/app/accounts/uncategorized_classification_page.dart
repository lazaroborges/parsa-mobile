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

class UncategorizedClassificationPage extends StatefulWidget {
  const UncategorizedClassificationPage({Key? key}) : super(key: key);

  @override
  State<UncategorizedClassificationPage> createState() =>
      _UncategorizedClassificationPageState();
}

class _UncategorizedClassificationPageState
    extends State<UncategorizedClassificationPage> {
  List<TransactionGroup> groups = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classificar Transações ('
            '\${groups.fold<int>(0, (sum, g) => sum + g.count)})'),
      ),
      body: FutureBuilder<List<TransactionGroup>>(
        future: getTopUncategorizedGroups(limit: 10),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          groups = snapshot.data!;
          if (groups.isEmpty) {
            return const Center(
                child: Text('Nenhuma transação não categorizada.'));
          }
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: CardSwiper(
                cardsCount: groups.length,
                cardBuilder: (context, index, percentX, percentY) {
                  return TransactionGroupCard(group: groups[index]);
                },
                numberOfCardsDisplayed: 1,
                onSwipe: (prev, curr, direction) async {
                  if (direction == CardSwiperDirection.right) {
                    final group = groups[prev];
                    final selectedCategory = await showCategoryPickerModal(
                      context,
                      modal: CategoryPicker(
                        selectedCategory: group.transactions.first.category,
                        categoryType: [
                          CategoryType.B,
                          CategoryType.E,
                          CategoryType.I
                        ],
                      ),
                    );
                    if (selectedCategory != null) {
                      await Future.wait(group.transactions.map((tx) =>
                          TransactionService.instance.insertOrUpdateTransaction(
                            tx.copyWith(
                                categoryID: drift.Value(selectedCategory.id)),
                          )));
                      setState(() {
                        groups.removeAt(prev);
                      });
                    }
                  }
                  return true;
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class InfoTileWithIconAndColor extends StatelessWidget {
  final dynamic icon;
  final String data;
  final Color color;
  final bool isAccount;
  final String? iconId;
  const InfoTileWithIconAndColor({
    Key? key,
    required this.icon,
    required this.data,
    required this.color,
    this.isAccount = false,
    this.iconId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAccount) ...[
          Image.asset(
            'assets/png_icons/${iconId ?? "1"}.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ] else ...[
          icon.display(
            color: color,
          ),
        ],
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            data,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

class TransactionSwipeCard extends StatelessWidget {
  final dynamic tx;
  const TransactionSwipeCard({Key? key, required this.tx}) : super(key: key);

  // Helper to parse color strings robustly (supports null, 0x, #, or plain int)
  Color _parseColor(String? colorStr) {
    if (colorStr == null) return const Color(0xFF888888);
    try {
      String hex = colorStr.trim();
      if (hex.startsWith('#')) {
        hex = hex.substring(1);
      }
      if (hex.startsWith('0x')) {
        hex = hex.substring(2);
      }
      if (hex.length == 6) {
        hex = 'FF$hex'; // add alpha if missing
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFF888888);
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = tx.category;
    final account = tx.account;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tx.title?.toString() ?? 'Sem título',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Valor: R\$ ${tx.value?.toStringAsFixed(2) ?? '--'}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.green, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (category != null)
              InfoTileWithIconAndColor(
                icon: category.icon,
                data: category.name ?? 'Não categorizada',
                color: _parseColor(category.color),
                isAccount: false,
                iconId: category.iconId,
              )
            else
              Text(
                'Categoria: Não categorizada',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 8),
            if (account != null)
              InfoTileWithIconAndColor(
                icon: account.icon,
                data: account.name ?? '---',
                color: account.getComputedColor(context),
                isAccount: true,
                iconId: account.iconId,
              )
            else
              Text(
                'Conta: ---',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 8),
            Text(
              'Data: ${tx.date != null ? tx.date.toLocal().toString().split(' ')[0] : '--'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (tx.notes != null && tx.notes.toString().isNotEmpty)
              Text(
                'Notas: ${tx.notes}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}

/// A single card showing a transaction group summary and detail list.
class TransactionGroupCard extends StatefulWidget {
  final TransactionGroup group;
  const TransactionGroupCard({Key? key, required this.group}) : super(key: key);
  @override
  State<TransactionGroupCard> createState() => _TransactionGroupCardState();
}

class _TransactionGroupCardState extends State<TransactionGroupCard> {
  @override
  Widget build(BuildContext context) {
    final g = widget.group;

    // Find the first non-transfer transaction title to use as card title
    String cardTitle = 'Transações não categorizadas';
    for (var tx in g.transactions) {
      if (tx.title != null &&
          tx.title != 'Transferência Recebida' &&
          tx.title!.isNotEmpty) {
        cardTitle = tx.title!;
        break;
      }
    }

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Highlight transaction count and total value
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.group_work_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${g.count} transações',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  CurrencyDisplayer(
                    amountToConvert: g.totalValue,
                    integerStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: g.totalValue >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Title from the first meaningful transaction
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                cardTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 12),

            // Use CardWithHeader to display transactions - this takes most of the space
            Expanded(
              child: CardWithHeader(
                title: 'Transações deste grupo',
                bodyPadding: EdgeInsets.zero,
                body: TransactionListComponent(
                  heroTagBuilder: (tr) => 'class-page__tr-icon-${tr.id}',
                  filters: TransactionFilters(
                    cousinFilter: g.cousin,
                  ),
                  limit: 100,
                  accountNameMaxLength: 10,
                  showGroupDivider: false,
                  showDate: true,
                  prevPage: const UncategorizedClassificationPage(),
                  onEmptyList: const Text('Nenhuma transação encontrada'),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Instructions at the bottom - more compact
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swipe, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Deslize para a direita para categorizar todas estas transações.',
                      style: Theme.of(context).textTheme.bodySmall,
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
