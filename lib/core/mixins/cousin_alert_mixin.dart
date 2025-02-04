import 'package:flutter/material.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/app_colors.dart';

mixin CousinAlertMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    _setupCousinHandler();
  }

  void _setupCousinHandler() {
    TransactionService.onCousinFound = _handleCousinFound;
  }

  Future<bool?> _handleCousinFound(int cousins) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Transações vinculadas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Existem $cousins transações relacionadas. Deseja continuar com a alteração?',
          style: Theme.of(context).textTheme.bodyMedium,
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