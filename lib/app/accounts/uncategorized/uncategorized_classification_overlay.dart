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
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/utils/open_external_url.dart';
import 'package:parsa/app/accounts/uncategorized/instruction_card.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/app/transactions/form/dialogs/transaction_status_selector.dart';
import 'package:parsa/i18n/translations.g.dart';

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
            child: _UncategorizedClassificationContent(),
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
  List<TransactionGroupByType>? _groups; // State variable for card data
  final CardSwiperController _cardController = CardSwiperController();
  final Set<int> _processedIndices = <int>{}; // Track processed cards

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TransactionGroupByType>>(
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
        // Filter out processed groups
        final availableGroups = groups
            .asMap()
            .entries
            .where((entry) => !_processedIndices.contains(entry.key))
            .map((entry) => entry.value)
            .toList();

        if (availableGroups.isEmpty) {
          return const Center(
              child: Text('Todas as transações foram categorizadas!'));
        }

        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.75,
            child: CardSwiper(
              cardsCount: groups.length + 1, // +1 for instruction card
              cardBuilder: (context, index, percentX, percentY) {
                // First card is instruction card
                if (index == 0) {
                  return const InstructionCard();
                }
                // Subsequent cards are transaction groups (adjust index)
                final group = groups[index - 1];
                return _LabeledTransactionGroupCard(group: group);
              },
              numberOfCardsDisplayed: 3,
              allowedSwipeDirection: AllowedSwipeDirection.only(
                left: true,
                right: true,
              ),
              onSwipe: (prev, curr, direction) async {
                // Skip processing for instruction card (index 0)
                if (prev == 0) {
                  return true;
                }

                // await AppSoundPlayer.playSwipeSound();
                if (direction == CardSwiperDirection.right) {
                  final group = groups[prev - 1]; // Adjust index for groups
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
                    // Process categorization immediately after selection
                    await _processCategorySelection(group, selectedCategory);
                    // Mark this card as processed using the original index
                    setState(() {
                      _processedIndices.add(prev - 1);
                    });
                    // Return false to prevent automatic swipe completion
                    // since we're handling the card removal through setState
                    return false;
                  }

                  // If no category selected or not confirmed, prevent swipe
                  return false;
                }
                return true; // Allow left swipes (dismiss)
              },
              onEnd: () async {
                print('[DEBUG] onEnd callback triggered');

                // Store the current navigator for later use
                final navigator = Navigator.of(context, rootNavigator: true);

                // First close the overlay
                navigator.pop();

                // Wait to ensure overlay is fully closed
                await Future.delayed(const Duration(milliseconds: 500));

                // try {
                // print('[DEBUG] Showing loading dialog');
                // // Show loading dialog with spinning logo (don't await it)
                // showDialog(
                //   context: navigator.context,
                //   barrierDismissible: false,
                //   useRootNavigator: false,
                //   builder: (dialogContext) => const _SummaryLoadingDialog(),
                // );

                // // Wait for "processing" time - 5 seconds
                // await Future.delayed(const Duration(seconds: 5));

                // Close loading dialog
                // Navigator.of(navigator.context).pop();

                // // Small delay before showing next dialog
                // await Future.delayed(const Duration(milliseconds: 300));

                // // Show summary ready dialog
                // showDialog(
                //   context: navigator.context,
                //   barrierDismissible: false,
                //   useRootNavigator: false,
                //   builder: (dialogContext) => const _SummaryReadyDialog(),
                // );
                // } catch (e) {
                //   print('[DEBUG] Error in dialog flow: $e');
                // }
              },
            ),
          ),
        );
      },
    );
  }

  Future<List<TransactionGroupByType>> _getTop10Groups() async {
    print('[PERF] [OVERLAY] _getTop10Groups: START');
    final startTime = DateTime.now();

    // Use the optimized method that fetches everything in one pass
    final result = await getTop10UncategorizedGroupsOptimized();

    final endTime = DateTime.now();
    print(
        '[PERF] [OVERLAY] _getTop10Groups: TOTAL ${endTime.difference(startTime).inMilliseconds}ms (OPTIMIZED)');
    return result;
  }

  /// Processes the category selection by updating transactions and cousin rules
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

      // await AppSoundPlayer.playSuccessSound();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${group.count} transação(ões) categorizadas como "${selectedCategory.name}"',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
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

  Future<void> _updateCategory(BuildContext context) async {
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
      await Future.wait(group.transactions
          .map((tx) => TransactionService.instance.insertOrUpdateTransaction(
                tx.copyWith(categoryID: drift.Value(selectedCategory.id)),
                null,
                1,
              )));

      final triggeringId = group.transactions.first.id.toString();
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Categoria atualizada: ${selectedCategory.name}')),
        );
      } catch (e) {
        print('Failed to update cousin rules: $e');
      }
    }
  }

  Future<void> _updateStatus(BuildContext context) async {
    final t = Translations.of(context);
    final modalResult = await showTransactioStatusModal(
      context,
      initialStatus: group.transactions.first.status,
    );

    if (modalResult != null && modalResult.result != null) {
      await Future.wait(group.transactions
          .map((tx) => TransactionService.instance.insertOrUpdateTransaction(
                tx.copyWith(status: drift.Value(modalResult.result)),
                null,
                1,
              )));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Status atualizado: ${modalResult.result!.displayName(context)}')),
      );
    }
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
                  prevPage: const UncategorizedClassificationOverlay(),
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
                    onPressed: () => _updateCategory(context),
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
                    onPressed: () => _updateStatus(context),
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
class _SummaryReadyDialog extends StatelessWidget {
  const _SummaryReadyDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: const Color(0xFFF8F9FE),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Relatório Pronto!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: appColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Seu relatório foi gerado com sucesso',
                  style: TextStyle(
                    fontSize: 14,
                    color: appColors.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Download button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement download functionality
                      Navigator.of(context, rootNavigator: true).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Download iniciado...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Baixar Relatório'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.primary,
                      foregroundColor: appColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Open on web button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Replace with actual web URL
                      openExternalURL(
                          context, 'https://app.parsa-ai.com.br/relatorios');
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Abrir na Web'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: appColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: appColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Close button positioned at top right
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              icon: Icon(
                Icons.close,
                color: appColors.onSurface.withOpacity(0.7),
              ),
              style: IconButton.styleFrom(
                backgroundColor: appColors.surface.withOpacity(0.8),
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
