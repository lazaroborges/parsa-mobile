import 'package:flutter/material.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';

mixin CousinAlertMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    _setupCousinHandler();
  }

  void _setupCousinHandler() {
    TransactionService.onCousinFound = _handleCousinFound;
  }

  Future<bool?> _handleCousinFound(int cousins, int cousinValue, TransactionChanges changes) async {
    print('Cousin found: $cousins, $cousinValue ${cousinValue.runtimeType} $changes');
    
    // Build changes description
    final List<String> changesList = [];
    if (changes.description != null) changesList.add('descrição');
    if (changes.categoryId != null) changesList.add('categoria');
    if (changes.status != null) changesList.add('status');
    if (changes.notes != null) changesList.add('notas');
    if (changes.tags != null) changesList.add('tags');
    
    final changesText = changesList.isEmpty 
        ? ''
        : '\n\nMudanças detectadas em: ${changesList.join(', ')}.';

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
                    maxHeight: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                    minHeight: 100, // minimum height to look good
                  ),
                  child: TransactionListComponent(
                    heroTagBuilder: (tr) => 'cousin-alert__tr-icon-${tr.id}',
                    filters: TransactionFilters(
                      cousinFilter: cousinValue,
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
                  value: true,
                  onChanged: (value) => setState(() {}),
                  title: const Text(
                    'Aplicar a todas as transações existentes e futuras',
                    style: TextStyle(fontSize: 14),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              
              backgroundColor: AppColors.of(context).primary,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    
    // Only return a boolean if the user explicitly chose an option
    // Return null if dialog was dismissed
    return result;
  }

  @override
  void dispose() {
    TransactionService.onCousinFound = null;
    super.dispose();
  }
}
