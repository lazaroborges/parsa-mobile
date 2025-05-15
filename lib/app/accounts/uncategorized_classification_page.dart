import 'package:flutter/material.dart';
import 'package:parsa/app/categories/selectors/category_picker.dart';
import 'package:parsa/core/models/category/category.dart';
import 'package:parsa/core/utils/transaction_utils.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class UncategorizedClassificationPage extends StatefulWidget {
  final int transactionCount;
  const UncategorizedClassificationPage(
      {Key? key, required this.transactionCount})
      : super(key: key);

  @override
  State<UncategorizedClassificationPage> createState() =>
      _UncategorizedClassificationPageState();
}

class _UncategorizedClassificationPageState
    extends State<UncategorizedClassificationPage> {
  List uncategorized = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classificar Transações')),
      body: FutureBuilder<List>(
        future: getTransactionsByCategoryName('Lazer'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final transactions = snapshot.data!;
          if (transactions.isEmpty) {
            return const Center(
                child: Text('Nenhuma transação encontrada para "Lazer"!'));
          }
          uncategorized = List.from(transactions);
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              child: CardSwiper(
                cardsCount: uncategorized.length,
                cardBuilder: (context, index, percentX, percentY) {
                  final tx = uncategorized[index];
                  return TransactionSwipeCard(tx: tx);
                },
                numberOfCardsDisplayed: 3,
                onSwipe: (int previousIndex, int? currentIndex,
                    CardSwiperDirection direction) async {
                  final tx = uncategorized[previousIndex];
                  if (direction == CardSwiperDirection.left) {
                    setState(() {
                      uncategorized.removeAt(previousIndex);
                    });
                  } else if (direction == CardSwiperDirection.right) {
                    final selectedCategory = await showCategoryPickerModal(
                      context,
                      modal: CategoryPicker(
                        selectedCategory: tx.category,
                        categoryType: [
                          CategoryType.B,
                          CategoryType.E,
                          CategoryType.I
                        ],
                      ),
                    );
                    if (selectedCategory != null) {
                      setState(() {
                        uncategorized.removeAt(previousIndex);
                      });
                    }
                  } else if (direction == CardSwiperDirection.top) {
                    setState(() {
                      uncategorized.removeAt(previousIndex);
                    });
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
