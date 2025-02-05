import 'package:flutter/material.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/app/transactions/widgets/transaction_list.dart'; // Import the TransactionListComponent
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

  Future<bool?> _handleCousinFound(int cousins, int cousinValue) async {
    print('Cousin found: $cousins, $cousinValue ${cousinValue.runtimeType}');
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Transações Similares',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Existem $cousins transações similares ao grupo "$cousinValue". Você gostaria de ver e atualizar todas elas?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: CardWithHeader(
                  
                  title: 'Transações Similares',
                  bodyPadding: const EdgeInsets.all(16),
                  body: TransactionListComponent(
                    heroTagBuilder: (tr) => 'cousin-alert__tr-icon-${tr.id}',
                    filters: TransactionFilters(
                      cousinFilter: cousinValue,
                    ),
                    prevPage: Navigator.canPop(context) 
                        ? context.widget 
                        : const SizedBox.shrink(),
                    showGroupDivider: false,
                    onEmptyList: const Text('Nenhuma transação encontrada'),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Cancelar'),
          ),
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
  }

  @override
  void dispose() {
    TransactionService.onCousinFound = null;
    super.dispose();
  }
}
