import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parsa/main.dart';
import 'package:parsa/core/models/category/category.dart';
import 'package:parsa/core/utils/cousin_utils.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:drift/drift.dart' as drift;
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/app/categories/selectors/category_picker.dart';
import 'package:parsa/core/api/post_methods/post_user_cousin_rules.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/models/transaction/transaction_type.enum.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/app/transactions/cousin/instruction_card.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/app/transactions/form/dialogs/transaction_status_selector.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class CousinClassificationOverlay extends StatefulWidget {
  final List<TransactionGroupByType> groups;
  final int? totalTransactions;
  final int? totalGroups;
  final String? periodLabel;

  const CousinClassificationOverlay({
    Key? key,
    required this.groups,
    this.totalTransactions,
    this.totalGroups,
    this.periodLabel,
  }) : super(key: key);

  @override
  State<CousinClassificationOverlay> createState() =>
      _CousinClassificationOverlayState();
}

class _CousinClassificationOverlayState
    extends State<CousinClassificationOverlay> {
  // DEV-MODE: Set to `false` to test the normal behavior (card shown only once)
  static const bool _debugAlwaysShowInstructionCard = false;

  final CardSwiperController _cardController = CardSwiperController();
  final Set<int> _processedIndices = <int>{};
  bool _hasShownInstructionCardBefore = false;
  bool _isProgrammaticSwipe = false;
  bool _skipNextSwipeModal = false;

  @override
  void initState() {
    super.initState();
    _loadInstructionCardPreference();
  }

  Future<void> _loadInstructionCardPreference() async {
    // If in debug mode and the flag is set, always show the card
    if (kDebugMode && _debugAlwaysShowInstructionCard) {
      if (mounted) {
        setState(() {
          _hasShownInstructionCardBefore = false;
        });
      }
      return;
    }

    final hasShown =
        await SharedPreferencesAsync.instance.getFirstTriggerSwipeCards();
    if (mounted) {
      setState(() {
        _hasShownInstructionCardBefore = hasShown;
      });
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups;

    if (groups.isEmpty && _hasShownInstructionCardBefore) {
      return const Center(child: Text('Nenhuma transação não categorizada.'));
    }

    final bool shouldShowInstructionCardThisBuild =
        !_hasShownInstructionCardBefore;

    if (groups.isEmpty && shouldShowInstructionCardThisBuild) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const InstructionCard(),
        ),
      );
    }

    if (groups.isEmpty) {
      return const Center(child: Text('Nenhuma transação não categorizada.'));
    }

    final int totalCards =
        groups.length + (shouldShowInstructionCardThisBuild ? 1 : 0);

    final bool allProcessed = _processedIndices.length == groups.length;

    if (allProcessed && !shouldShowInstructionCardThisBuild) {
      return const Center(
          child: Text('Todas as transações foram categorizadas!'));
    }

    // If there is exactly one group, show the same swipe card UI and actions
    if (groups.length == 1) {
      final group = groups.first;
      return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.75,
          child: CardSwiper(
            controller: _cardController,
            cardsCount: 1,
            numberOfCardsDisplayed: 1,
            cardBuilder: (context, index, percentX, percentY) {
              return _LabeledTransactionGroupCard(
                group: group,
                onCategoryPressed: () =>
                    _handleCategorizeButtonPressed(group, 0),
                onStatusPressed: () => _handleStatusButtonPressed(group, 0),
              );
            },
            allowedSwipeDirection:
                AllowedSwipeDirection.only(left: true, right: true),
            onSwipe: (prev, curr, dir) async {
              if (_isProgrammaticSwipe) {
                _isProgrammaticSwipe = false;
                setState(() {
                  _processedIndices.add(0);
                });
                return true;
              }
              if (dir == CardSwiperDirection.right) {
                if (_skipNextSwipeModal) {
                  _skipNextSwipeModal = false;
                  setState(() {
                    _processedIndices.add(0);
                  });
                  return true;
                }
                final selectedCategory = await showCategoryPickerModal(
                  context,
                  modal: CategoryPicker(
                    selectedCategory: group.transactions.first.category,
                    categoryType: group.type == CategoryType.I
                        ? [CategoryType.B, CategoryType.I]
                        : [CategoryType.E, CategoryType.B],
                  ),
                );
                if (selectedCategory == null) {
                  return false;
                }
                setState(() {
                  _processedIndices.add(0);
                });
                unawaited(_processCategorySelection(group, selectedCategory)
                    .catchError((e) {
                  if (mounted) {
                    setState(() {
                      _processedIndices.remove(0);
                    });
                  }
                }));
                return true;
              }
              setState(() {
                _processedIndices.add(0);
              });
              return true;
            },
            onEnd: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.75,
        child: CardSwiper(
          controller: _cardController,
          cardsCount: totalCards,
          cardBuilder: (context, index, percentX, percentY) {
            if (shouldShowInstructionCardThisBuild) {
              if (index == 0) {
                return const InstructionCard();
              }

              final groupIndex = index - 1;
              if (_processedIndices.contains(groupIndex)) {
                return Container(); // Placeholder for processed card
              }
              final group = groups[groupIndex];
              return _LabeledTransactionGroupCard(
                group: group,
                onCategoryPressed: () =>
                    _handleCategorizeButtonPressed(group, groupIndex),
                onStatusPressed: () =>
                    _handleStatusButtonPressed(group, groupIndex),
              );
            } else {
              final groupIndex = index;
              if (_processedIndices.contains(groupIndex)) {
                return Container(); // Placeholder for processed card
              }
              final group = groups[groupIndex];
              return _LabeledTransactionGroupCard(
                group: group,
                onCategoryPressed: () =>
                    _handleCategorizeButtonPressed(group, groupIndex),
                onStatusPressed: () =>
                    _handleStatusButtonPressed(group, groupIndex),
              );
            }
          },
          numberOfCardsDisplayed: totalCards >= 3 ? 3 : totalCards,
          allowedSwipeDirection: const AllowedSwipeDirection.only(
            left: true,
            right: true,
          ),
          onSwipe:
              (prevCardSwiperIndex, currentCardSwiperIndex, direction) async {
            final bool instructionCardWasPresentThisBuild =
                shouldShowInstructionCardThisBuild;

            if (instructionCardWasPresentThisBuild &&
                prevCardSwiperIndex == 0) {
              if (!(kDebugMode && _debugAlwaysShowInstructionCard)) {
                await SharedPreferencesAsync.instance
                    .setFirstTriggerSwipeCards(true);
              }
              return true;
            }

            final int actualGroupIndex = instructionCardWasPresentThisBuild
                ? prevCardSwiperIndex - 1
                : prevCardSwiperIndex;

            if (_isProgrammaticSwipe) {
              _isProgrammaticSwipe = false;
              setState(() {
                _processedIndices.add(actualGroupIndex);
              });
              return true;
            }

            if (direction == CardSwiperDirection.right) {
              if (_skipNextSwipeModal) {
                _skipNextSwipeModal = false;
                setState(() {
                  _processedIndices.add(actualGroupIndex);
                });
                return true;
              }
              final group = groups[actualGroupIndex];
              final selectedCategory = await showCategoryPickerModal(
                context,
                modal: CategoryPicker(
                  selectedCategory: group.transactions.first.category,
                  categoryType: group.type == CategoryType.I
                      ? [CategoryType.B, CategoryType.I]
                      : [CategoryType.E, CategoryType.B],
                ),
              );

              if (selectedCategory == null) {
                return false; // User cancelled, so cancel the swipe
              }

              // Optimistically update state to remove the card from view
              setState(() {
                _processedIndices.add(actualGroupIndex);
              });

              // Process in background, without a disruptive rollback on manual swipe
              unawaited(_processCategorySelection(group, selectedCategory)
                  .catchError((e) {
                if (mounted) {
                  // On failure, silently re-enable the card in the deck
                  setState(() {
                    _processedIndices.remove(actualGroupIndex);
                  });
                }
              }));

              return true;
            }

            // For left swipes (dismiss)
            setState(() {
              _processedIndices.add(actualGroupIndex);
            });
            return true;
          },
          onEnd: () {
            if (shouldShowInstructionCardThisBuild) {
              Navigator.of(context).pop();
              tabsPageKey.currentState?.navigateToStatsTab(0);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  Future<void> _handleCategorizeButtonPressed(
      TransactionGroupByType group, int index) async {
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
      _skipNextSwipeModal = true;
      _cardController.swipe(CardSwiperDirection.right);
      setState(() {
        _processedIndices.add(index);
      });

      // Process in the background with unawaited
      unawaited(
          _processCategorySelection(group, selectedCategory).catchError((e) {
        // On failure, undo the swipe and revert the state
        if (mounted) {
          _cardController.undo();
          setState(() {
            _processedIndices.remove(index);
          });
        }
      }));
    }
  }

  Future<void> _handleStatusButtonPressed(
      TransactionGroupByType group, int index) async {
    final modalResult = await showTransactioStatusModal(
      context,
      initialStatus: group.transactions.first.status,
    );

    if (modalResult != null && modalResult.result != null) {
      _skipNextSwipeModal = true;
      _cardController.swipe(CardSwiperDirection.right);
      setState(() {
        _processedIndices.add(index);
      });

      unawaited(Future.wait(group.transactions
          .map((tx) => TransactionService.instance.insertOrUpdateTransaction(
                tx.copyWith(status: drift.Value(modalResult.result)),
                null,
                1,
              ))).catchError((e) {
        if (mounted) {
          _cardController.undo();
          setState(() {
            _processedIndices.remove(index);
          });
        }
      }));
    }
  }

  Future<void> _processCategorySelection(
    TransactionGroupByType group,
    Category selectedCategory,
  ) async {
    try {
      // Update all transactions in the group
      await Future.wait(group.transactions
          .map((tx) => TransactionService.instance.insertOrUpdateTransaction(
                tx.copyWith(categoryID: drift.Value(selectedCategory.id)),
                null,
                1,
              )));

      // Update cousin rules for future automatic categorization
      final triggeringId = group.transactions.first.id.toString();
      final cousinValue = group.cousin;
      final changes = {
        'categoryName': selectedCategory.name,
        'categoryId': selectedCategory.id,
      };

      await PostUserCousinRules.updateCousinRules(
        cousinValue: cousinValue,
        triggeringId: triggeringId,
        changes: changes,
        applyToFuture: true,
      );
    } catch (e) {
      print('Failed to process category selection: $e');

      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao categorizar transações'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

/// Card with a label for income/expense type and group summary
class _LabeledTransactionGroupCard extends StatelessWidget {
  final TransactionGroupByType group;
  final VoidCallback onCategoryPressed;
  final VoidCallback onStatusPressed;

  const _LabeledTransactionGroupCard({
    Key? key,
    required this.group,
    required this.onCategoryPressed,
    required this.onStatusPressed,
  }) : super(key: key);

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

    // Split into words and find first non-generic word
    final words = title.split(' ');
    int startIndex = -1;

    for (int i = 0; i < words.length; i++) {
      final word = words[i].trim();
      if (word.isNotEmpty &&
          !genericWords
              .any((generic) => generic.toLowerCase() == word.toLowerCase())) {
        startIndex = i;
        break;
      }
    }

    if (startIndex == -1) return 'Não identificado';

    // Join words from the first non-generic word onward
    final result = words.sublist(startIndex).join(' ').trim();

    // Clean special characters but keep basic punctuation
    final cleaned = result
        .replaceAll(RegExp('[^a-zA-Z0-9áéíóúãõâêîôûçÁÉÍÓÚÃÕÂÊÎÔÛÇ .-]'), '')
        .trim();

    if (cleaned.isEmpty) return 'Não identificado';
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final appColors = AppColors.of(context);
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
        padding: const EdgeInsets.all(16),
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
                        group.countInPeriod.toString(),
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
                        formatCurrency(group.totalValueInPeriod),
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
              title: 'Transações Similares',
              bodyPadding: EdgeInsets.zero,
              onHeaderButtonClick: () {
                RouteUtils.pushRoute(
                  context,
                  TransactionsPage(
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
                );
              },
              body: SizedBox(
                height: 75.0 * 4, // Fixed height for 4 transactions
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
                  prevPage: CousinClassificationOverlay(groups: const []),
                  onEmptyList: const Text('Nenhuma transação encontrada'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // --- New Action Buttons Row ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCategoryPressed,
                    icon: const Icon(Icons.category_rounded, size: 18),
                    label: Text(
                      t.general.category,
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.primary.withOpacity(0.1),
                      foregroundColor: appColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                            color: appColors.primary.withOpacity(0.3)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStatusPressed,
                    icon: Icon(
                      group.transactions.first.status?.icon ??
                          Icons.help_outline,
                      size: 18,
                    ),
                    label: Text(
                      'Status',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          appColors.primaryContainer.withOpacity(0.5),
                      foregroundColor: appColors.onPrimaryContainer,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: appColors.primaryContainer),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // --- Instructions Box (now at bottom) ---
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

/// Loading dialog with spinning logo animation
class _SummaryLoadingDialog extends StatefulWidget {
  const _SummaryLoadingDialog({Key? key}) : super(key: key);

  @override
  State<_SummaryLoadingDialog> createState() => _SummaryLoadingDialogState();
}

class _SummaryLoadingDialogState extends State<_SummaryLoadingDialog>
    with TickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: const Color(0xFFF8F9FE),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _spinController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _spinController.value * 2 * 3.14159,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.transparent),
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.transparent,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      'assets/resources/appIcon.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Gerando seu relatório',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Estamos processando suas transações...',
              style: TextStyle(
                fontSize: 14,
                color: appColors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Summary ready dialog with download and web options
// class _SummaryReadyDialog extends StatelessWidget {
//   const _SummaryReadyDialog({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final appColors = AppColors.of(context);

//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       elevation: 0,
//       backgroundColor: const Color(0xFFF8F9FE),
//       child: Stack(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Success icon
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.check_circle,
//                     size: 48,
//                     color: Colors.green,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'Relatório Pronto!',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: appColors.onSurface,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Seu relatório foi gerado com sucesso',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: appColors.onSurface.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 32),
//                 // Download button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       // TODO: Implement download functionality
//                       Navigator.of(context, rootNavigator: true).pop();
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Download iniciado...'),
//                         ),
//                       );
//                     },
//                     icon: const Icon(Icons.download),
//                     label: const Text('Baixar Relatório'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: appColors.primary,
//                       foregroundColor: appColors.onPrimary,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 // Open on web button
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       // TODO: Replace with actual web URL
//                       openExternalURL(
//                           context, 'https://app.parsa-ai.com.br/relatorios');
//                       Navigator.of(context, rootNavigator: true).pop();
//                     },
//                     icon: const Icon(Icons.open_in_new),
//                     label: const Text('Abrir na Web'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: appColors.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       side: BorderSide(color: appColors.primary),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Close button positioned at top right
//           Positioned(
//             top: 8,
//             right: 8,
//             child: IconButton(
//               onPressed: () {
//                 Navigator.of(context, rootNavigator: true).pop();
//               },
//               icon: Icon(
//                 Icons.close,
//                 color: appColors.onSurface.withOpacity(0.7),
//               ),
//               style: IconButton.styleFrom(
//                 backgroundColor: appColors.surface.withOpacity(0.8),
//                 shape: const CircleBorder(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
