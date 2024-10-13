import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:parsa/core/presentation/widgets/modal_container.dart';
import 'package:parsa/core/utils/constants.dart';
import 'package:parsa/i18n/translations.g.dart';

Future<String?> showTransactionNotesModal(
  BuildContext context, {
  required String? initialNotes,
}) {
  return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return TransactionNotesModal(
          initialNotes: initialNotes,
        );
      });
}

class TransactionNotesModal extends StatefulWidget {
  const TransactionNotesModal({super.key, required this.initialNotes});

  final String? initialNotes;

  @override
  State<TransactionNotesModal> createState() => _TransactionNotesModalState();
}

class _TransactionNotesModalState extends State<TransactionNotesModal> {
  FocusNode notesFocusNode = FocusNode();

  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    notesController.text = widget.initialNotes ?? '';
    notesFocusNode.requestFocus();
  }

  @override
  void dispose() {
    notesFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return ModalContainer(
      title: t.transaction.form.title,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      body: TextFormField(
        controller: notesController,
        maxLength: 250,
        decoration:
            InputDecoration(label: Text(t.transaction.form.title_short)),
        focusNode: notesFocusNode,
      ),
      footer: BottomSheetFooter(
        onSaved: () => Navigator.pop(context, notesController.text),
      ),
    );
  }
}
