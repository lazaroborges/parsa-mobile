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
                      // await AppSoundPlayer.playSuccessSound();
                    } catch (e) {
                      print('Failed to update cousin rules: $e');
                    }
                  }
                }
                return true;
              },
              onEnd: () async {
                print('[DEBUG] onEnd callback triggered');

                // Store the current navigator for later use
                final navigator = Navigator.of(context, rootNavigator: true);

                // First close the overlay
                navigator.pop();
                print('[DEBUG] Overlay closed');

                // Wait to ensure overlay is fully closed
                await Future.delayed(const Duration(milliseconds: 500));

                try {
                  print('[DEBUG] Showing loading dialog');
                  // Show loading dialog with spinning logo (don't await it)
                  showDialog(
                    context: navigator.context,
                    barrierDismissible: false,
                    useRootNavigator: false,
                    builder: (dialogContext) => const _SummaryLoadingDialog(),
                  );

                  // Wait for "processing" time - 5 seconds
                  await Future.delayed(const Duration(seconds: 5));
                  print('[DEBUG] Loading period completed');

                  // Close loading dialog
                  Navigator.of(navigator.context).pop();
                  print('[DEBUG] Loading dialog closed');

                  // Small delay before showing next dialog
                  await Future.delayed(const Duration(milliseconds: 300));

                  print('[DEBUG] Showing summary dialog');
                  // Show summary ready dialog
                  showDialog(
                    context: navigator.context,
                    barrierDismissible: false,
                    useRootNavigator: false,
                    builder: (dialogContext) => const _SummaryReadyDialog(),
                  );
                  print('[DEBUG] Summary dialog shown successfully');
                } catch (e) {
                  print('[DEBUG] Error in dialog flow: $e');
                }
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
                  prevPage: const UncategorizedClassificationOverlay(),
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
