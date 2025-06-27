import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';

class CreditCardListCard extends StatefulWidget {
  const CreditCardListCard({
    super.key,
    required this.creditCards,
    required this.onCardTap,
    required this.onAddCardTap,
    this.title = 'Cartões',
  });

  final List<Account> creditCards;
  final Function(Account) onCardTap;
  final VoidCallback onAddCardTap;
  final String title;

  @override
  State<CreditCardListCard> createState() => _CreditCardListCardState();
}

class _CreditCardListCardState extends State<CreditCardListCard> {
  final Map<String, String> _iconPathCache = {};

  Future<String> _getIconPath(String iconId) async {
    if (_iconPathCache.containsKey(iconId)) {
      return _iconPathCache[iconId]!;
    }

    final defaultPath = 'assets/png_icons/$iconId.png';
    const fallbackPath = 'assets/png_icons/1.png';

    try {
      await rootBundle.load(defaultPath);
      _iconPathCache[iconId] = defaultPath;
      return defaultPath;
    } catch (_) {
      _iconPathCache[iconId] = fallbackPath;
      return fallbackPath;
    }
  }

  Widget _buildCardIcon(String iconId) {
    return FutureBuilder<String>(
      future: _getIconPath(iconId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Image.asset(
            'assets/png_icons/1.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          );
        }

        return Image.asset(
          snapshot.data!,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          cacheWidth: 64,
          cacheHeight: 64,
        );
      },
    );
  }

  String _cleanCardName(String cardName) {
    // Same logic as account name cleaning
    final bankNames = [
      'Itaú',
      'Nubank Empresas',
      'Nubank',
      'Banco do Brasil',
      'Bradesco',
      'Santander',
      'Caixa',
      'Caixa Econômica',
      'Inter',
      'BTG',
      'BTG Pactual',
      'C6 Bank',
      'XP',
      'Neon',
      'PicPay',
      'Original',
      'Banrisul',
      'Sicoob',
      'Next',
      'BS2',
      'BV',
      'Banco BV',
      'Will Bank',
      'Mercado Pago',
      'PagBank',
    ];

    for (final bankName in bankNames) {
      final pattern = RegExp('^$bankName\\s+', caseSensitive: false);
      if (pattern.hasMatch(cardName)) {
        return cardName.replaceFirst(pattern, '');
      }
    }

    return cardName;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.creditCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return CardWithHeader(
      title: widget.title,
      headerButtonIcon: Icons.add,
      onHeaderButtonClick: widget.onAddCardTap,
      bodyPadding: EdgeInsets.zero,
      body: Column(
        children: widget.creditCards.map((card) {
          // Calculate dates (dummy data for now)
          final DateTime nextInvoiceDate =
              DateTime.now().add(const Duration(days: 15));
          final double currentInvoice = 2340.75; // Example current invoice

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.onCardTap(card),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
                    top: card == widget.creditCards.first ? 12 : 0, bottom: 8),
                child: Column(
                  children: [
                    if (card != widget.creditCards.first)
                      const Divider(height: 8, indent: 0),
                    Row(
                      children: [
                        _buildCardIcon(card.iconId),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cleanCardName(card.name),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Vence em ${nextInvoiceDate.day}/${nextInvoiceDate.month}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Próxima fatura',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            CurrencyDisplayer(
                              amountToConvert: currentInvoice,
                              currency: card.currency,
                              integerStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
