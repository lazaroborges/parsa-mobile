import 'package:flutter/material.dart';
import 'package:parsa/core/database/backup/backup_database_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/i18n/translations.g.dart';

import 'widgets/settings_list_separator.dart';

class BackupSettingsPage extends StatelessWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.more.data.display)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              kToolbarHeight -
              MediaQuery.of(context).padding.top,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              createListSeparator(context, t.backup.export.title_short),
              ListTile(
                title: Text(t.backup.export.title),
                subtitle: Text(t.backup.export.description),
                minVerticalPadding: 16,
                onTap: () async {
                  final messeger = ScaffoldMessenger.of(context);

                  await BackupDatabaseService()
                      .exportSpreadsheet(
                          context,
                          await TransactionService.instance
                              .getTransactions()
                              .first)
                      .then((value) {
                    messeger.showSnackBar(SnackBar(
                      content: Text(t.backup.export.success(x: value)),
                    ));
                  }).catchError((err) {
                    messeger.showSnackBar(SnackBar(
                      content: Text('$err'),
                    ));
                  });
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
