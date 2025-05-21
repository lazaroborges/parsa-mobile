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
  List<TransactionGroupByType> interleavedGroups = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reclassificar Transações'),
      ),
      body: FutureBuilder<List<TransactionGroupByType>>(
        future: getTopUncategorizedGroupsByCousinTotalAmount(limit: 10),
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
            // Only one card, show it centered
            final group = groups.first;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _LabeledTransactionGroupCard(group: group),
              ),
            );
          }

          // 2 or more: use CardSwiper
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: CardSwiper(
                cardsCount: groups.length,
                cardBuilder: (context, index, percentX, percentY) {
                  final group = groups[index];
                  return _LabeledTransactionGroupCard(group: group);
                },
                numberOfCardsDisplayed: 2,
                onSwipe: (prev, curr, direction) async {
                  // Play swipe sound on every swipe
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
                            1, // notMassUpdate: 1 to suppress cousin modal
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
                        // Play success sound after successful recategorization
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
            ),
          );
        },
      ),
    );
  }
}

/// Card with a label for income/expense type
class _LabeledTransactionGroupCard extends StatelessWidget {
  final TransactionGroupByType group;
  const _LabeledTransactionGroupCard({Key? key, required this.group})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: group.type == CategoryType.I
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            group.type == CategoryType.I ? 'Receita' : 'Despesa',
            style: TextStyle(
              color: group.type == CategoryType.I ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TransactionGroupCardByType(group: group),
      ],
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
                color: category.color != null
                    ? ColorHex.get(category.color)
                    : const Color(0xFF888888),
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

/// A single card showing a transaction group summary and detail list, by cousin and type.
class TransactionGroupCardByType extends StatelessWidget {
  final TransactionGroupByType group;
  const TransactionGroupCardByType({Key? key, required this.group})
      : super(key: key);

  void _reviewAll(BuildContext context) {
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
            // Add other filters as needed
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = group;
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

    // Instructional rules above the card
    final instructions = Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Deslize para direita para reclassificar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Text(
            'Deslize para esquerda para descartar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      color:
                          g.type == CategoryType.I ? Colors.green : Colors.red,
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
            SizedBox(
              height: 88.0 * 4, // Approximate height for 4 transactions
              child: CardWithHeader(
                title: 'Transações deste grupo',
                bodyPadding: EdgeInsets.zero,
                body: TransactionListComponent(
                  heroTagBuilder: (tr) => 'class-page__tr-icon-${tr.id}',
                  filters: TransactionFilters(
                    cousinFilter: g.cousin,
                    status: [
                      TransactionStatus.pending,
                      TransactionStatus.reconciled,
                      TransactionStatus.unreconciled,
                      TransactionStatus.voided,
                    ],
                    transactionTypes: [
                      g.type == CategoryType.I
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
            Center(
              child: TextButton.icon(
                onPressed: () => _reviewAll(context),
                icon: const Icon(Icons.list_alt),
                label: const Text('Ver todas as transações'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ),
            instructions,
            // Highlight transaction count and total value
          ],
        ),
      ),
    );
  }
}

// Full transaction list page for a cousin group
class FullTransactionListPage extends StatelessWidget {
  final int cousin;
  final Widget prevPage;
  const FullTransactionListPage(
      {Key? key, required this.cousin, required this.prevPage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Todas as transações do grupo'),
      ),
      body: CardWithHeader(
        title: 'Todas as transações',
        body: TransactionListComponent(
          heroTagBuilder: (tr) => 'review-page__tr-icon-${tr.id}',
          filters: TransactionFilters(
            cousinFilter: cousin,
            status: [
              TransactionStatus.pending,
              TransactionStatus.reconciled,
              TransactionStatus.unreconciled,
              TransactionStatus.voided,
            ],
          ),
          limit: 100,
          accountNameMaxLength: 10,
          showGroupDivider: false,
          showDate: true,
          prevPage: prevPage,
          onEmptyList: const Text('Nenhuma transação encontrada'),
        ),
      ),
    );
  }
}
