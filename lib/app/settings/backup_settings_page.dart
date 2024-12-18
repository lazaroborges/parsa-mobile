import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parsa/app/settings/export_page.dart';
import 'package:parsa/app/settings/import_csv.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/backup/backup_database_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/extensions/numbers.extensions.dart';
import 'package:parsa/core/presentation/widgets/confirm_dialog.dart';
import 'package:parsa/core/routes/destinations.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/core/utils/open_external_url.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/main.dart';

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
          height: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top,
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
                        .first
                    )
                    .then((value) {
                      messeger.showSnackBar(SnackBar(
                        content: Text(t.backup.export.success(x: value)),
                      ));
                    })
                    .catchError((err) {
                      messeger.showSnackBar(SnackBar(
                        content: Text('$err'),
                      ));
                    });
                },
              ),
              const Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48 ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Você gostaria de importar seus dados? ',
                          style: TextStyle(
                            color: Color(0xFF475466),
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: 'Fale com a gente',
                          style: TextStyle(
                            color: Color(0xFF475466),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => openExternalURL(
                                context, 'https://wa.me/5531972012338?text=Gostaria%20de%20importar%20meus%20dados%20no%20Parsa'),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
