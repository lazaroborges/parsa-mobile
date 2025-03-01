import 'package:flutter/material.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/core/api/post_methods/post_user_cousin_rules.dart';

mixin CousinAlertMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    _setupCousinHandler();
  }

  void _setupCousinHandler() {
    TransactionService.onCousinFound = _handleCousinFound;
  }

  Future<bool?> _handleCousinFound(int cousins, String triggeringId, int cousinValue, bool positiveInflow, TransactionChanges changes) async {
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

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AlertDialog(
      title: Text(
        'Transações Similares',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Existem $cousins transações similares. Você gostaria de ver e atualizar todas elas?$changesText',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            CardWithHeader(
              title: 'Transações Similares',
              bodyPadding: const EdgeInsets.all(8),
              body: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                  minHeight: 100,
                ),
                child: TransactionListComponent(
                  heroTagBuilder: (tr) => 'cousin-alert__tr-icon-${tr.id}',
                  filters: TransactionFilters(
                    cousinFilter: cousinValue,
                    positiveValuesOnly: positiveInflow,
                  ),
                  limit: 3,
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
                value: _applyToFuture, // Use the _applyToFuture variable
                onChanged: (value) => setState(() {
                  _applyToFuture = value ?? false; // Update the variable
                }),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
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
              child: const Text('Revisar'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await PostUserCousinRules.updateCousinRules(
                    cousinValue: cousinValue,
                    triggeringId: triggeringId,
                    changes: changes.toJson(),
                    applyToFuture: _applyToFuture, // Use the _applyToFuture variable
                  );
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
  );
  
  return result;
}

  @override
  void dispose() {
    TransactionService.onCousinFound = null;
    super.dispose();
  }
}
