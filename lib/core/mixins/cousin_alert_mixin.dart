import 'package:flutter/material.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/core/api/post_methods/post_user_cousin_rules.dart';
import 'package:parsa/core/presentation/audio/app_sound_player.dart';
import 'package:parsa/core/services/review/review_service.dart';

mixin CousinAlertMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    _setupCousinHandler();
  }

  void _setupCousinHandler() {
    TransactionService.onCousinFound = _handleCousinFound;
  }

  Future<bool?> _handleCousinFound(int cousins, String triggeringId,
      int cousinValue, bool positiveInflow, TransactionChanges changes) async {
    if (cousins <= 1) {
      return null;
    }

    // Build changes description
    final List<String> changesList = [];
    if (changes.description != null) changesList.add('Descrição');
    if (changes.categoryName != null) changesList.add('Categoria');
    if (changes.status != null) changesList.add('Considerada');
    if (changes.notes != null) changesList.add('Notas');
    if (changes.tags != null) changesList.add('Tags');

    final changesText = changesList.isEmpty
        ? ''
        : '\n\nMudanças detectadas em: ${changesList.join(', ')}.';

    bool _applyToFuture = true;

    // Check screen height to determine transaction limit
    final screenHeight = MediaQuery.of(context).size.height;
    final transactionLimit = screenHeight < 700 ? 2 : 3;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      'Transações Similares',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Content
                  Text(
                    'Existem $cousins transações similares. Você gostaria de ver e atualizar todas elas?$changesText',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  CardWithHeader(
                    title: 'Transações Similares',
                    bodyPadding: const EdgeInsets.all(8),
                    onHeaderTap: () {
                      Navigator.pop(context);
                      RouteUtils.pushRoute(
                        context,
                        TransactionsPage(
                          filters: TransactionFilters(
                            cousinFilter: cousinValue,
                          ),
                        ),
                      );
                    },
                    body: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                        minHeight: 100,
                      ),
                      child: TransactionListComponent(
                        heroTagBuilder: (tr) =>
                            'cousin-alert__tr-icon-${tr.id}',
                        filters: TransactionFilters(
                          cousinFilter: cousinValue,
                          positiveValuesOnly: positiveInflow,
                        ),
                        limit: transactionLimit,
                        accountNameMaxLength: 8,
                        prevPage: Navigator.canPop(context)
                            ? context.widget
                            : const SizedBox.shrink(),
                        showGroupDivider: false,
                        showDate: true,
                        onEmptyList: const Text('Nenhuma transação encontrada'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (context, setState) => CheckboxListTile(
                      title: const Text(
                        'Aplicar automaticamente para transações futuras',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: _applyToFuture,
                      onChanged: (value) => setState(() {
                        _applyToFuture = value ?? false;
                      }),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          try {
                            await PostUserCousinRules.updateCousinRules(
                              cousinValue: cousinValue,
                              triggeringId: triggeringId,
                              changes: {},
                              applyToFuture: false,
                              dontAskAgain: true,
                            );
                            Navigator.pop(context, false);
                          } catch (e) {
                            print(
                                'Failed to update cousin rules (don\'t ask again): $e');
                            Navigator.pop(context, false);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: const Text('Nunca Perguntar'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          try {
                            await PostUserCousinRules.updateCousinRules(
                              cousinValue: cousinValue,
                              triggeringId: triggeringId,
                              changes: changes.toJson(),
                              applyToFuture: _applyToFuture,
                            );
                            // Play success sound after successful recategorization
                            // await AppSoundPlayer.playSuccessSound();
                            await ReviewService.instance
                                .incrementInteractionCount();
                            Navigator.pop(context, true);
                          } catch (e) {
                            print('Failed to update cousin rules: $e');
                            Navigator.pop(context, false);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.of(context).primary,
                        ),
                        child: const Text('Aprovar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Close button positioned at the top-right corner inside the dialog
            Positioned(
              top: 12,
              right: 12,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.close, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  @override
  void dispose() {
    TransactionService.onCousinFound = null;
    super.dispose();
  }
}
