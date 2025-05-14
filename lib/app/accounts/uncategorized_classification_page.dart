import 'package:flutter/material.dart';

// Mock Transaction model for demonstration
class Transaction {
  final String id;
  final String description;
  String category;
  Transaction(
      {required this.id, required this.description, required this.category});

  Transaction copyWith({String? category}) {
    return Transaction(
      id: id,
      description: description,
      category: category ?? this.category,
    );
  }
}

const List<String> UNCATEGORIZED_CATEGORIES = [
  "04000000",
  "04010000",
  "04020000",
  "04030000",
  "05000000",
  "05010000",
  "05020000",
  "05030000",
  "05040000",
  "05050000",
  "05060000",
  "05070000",
  "05080000",
  "05090000",
  "05090001",
  "05090002",
  "05090003",
  "05090004",
  "05090005",
  "99999998",
  "99999999"
];

class UncategorizedClassificationPage extends StatefulWidget {
  final int transactionCount; // Not used anymore, but kept for compatibility
  const UncategorizedClassificationPage(
      {Key? key, required this.transactionCount})
      : super(key: key);

  @override
  State<UncategorizedClassificationPage> createState() =>
      _UncategorizedClassificationPageState();
}

class _UncategorizedClassificationPageState
    extends State<UncategorizedClassificationPage> {
  List<Transaction> uncategorized = [];
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUncategorized();
  }

  Future<void> _fetchUncategorized() async {
    // TODO: Replace this mock with your real fetch logic
    // Simulate fetching all transactions and filter by uncategorized categories
    await Future.delayed(const Duration(milliseconds: 500));
    final allTransactions = [
      Transaction(id: '1', description: 'Uber', category: '04000000'),
      Transaction(id: '2', description: 'Mercado', category: '05000000'),
      Transaction(id: '3', description: 'Restaurante', category: '99999999'),
      Transaction(
          id: '4',
          description: 'Salário',
          category: '01010000'), // Not uncategorized
    ];
    setState(() {
      uncategorized = allTransactions
          .where((tx) => UNCATEGORIZED_CATEGORIES.contains(tx.category))
          .toList();
      isLoading = false;
    });
  }

  void _onReclassify(Transaction updated) async {
    // TODO: Call your backend to update the transaction
    // await updateTransactionCategory(updated);
    setState(() {
      uncategorized.removeAt(currentIndex);
      if (currentIndex >= uncategorized.length) {
        // All done!
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Classificação concluída!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (uncategorized.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Classificar Transações')),
        body: const Center(child: Text('Nenhuma transação não categorizada!')),
      );
    }

    final transaction = uncategorized[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Classificar Transações')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Transação: ${transaction.description}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Text('Categoria atual: ${transaction.category}',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            // Replace with your category picker widget
            ElevatedButton(
              onPressed: () {
                // Simulate reclassification
                _onReclassify(transaction.copyWith(category: '01010000'));
              },
              child: const Text('Reclassificar como "Salário"'),
            ),
            const SizedBox(height: 24),
            Text('Restantes: ${uncategorized.length - 1}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
