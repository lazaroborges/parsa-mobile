import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/app-data/app_data_service.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/utils/get_download_path.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupDatabaseService {
  AppDB db = AppDB.instance;

  Future<void> downloadDatabaseFile(BuildContext context) async {
    final messeger = ScaffoldMessenger.of(context);

    List<int> dbFileInBytes = await File(await db.databasePath).readAsBytes();

    String downloadPath = await getDownloadPath();
    downloadPath = path.join(
      downloadPath,
      "parsa-${DateFormat('yyyyMMdd-Hms').format(DateTime.now())}.db",
    );

    File downloadFile = File(downloadPath);

    await downloadFile.writeAsBytes(dbFileInBytes);

    messeger.showSnackBar(SnackBar(
      content: Text('Base de datos descargada con exito en $downloadPath'),
    ));
  }

  Future<String> exportSpreadsheet(
    BuildContext context,
    List<MoneyTransaction> data, {
    String format = 'csv',
    String separator = ';',
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'Transactions-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}.csv';
    final filePath = '${directory.path}/$fileName';
    
    var csvData = '';

    var keys = [
      'ID',
      'Quantidade',
      'Data',
      'Nome',
      'Comentários  ',
      'Conta',
      'Moeda',
      'Categoria',
      'Subcategoria',
      'Insights',
      'Editada pelo usuário',
      
    ];

    if (data.isNotEmpty) {
      for (final key in keys) {
        csvData += key + separator;
      }
    }

    csvData += '\n';

    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (final transaction in data) {
      final toAdd = [
        transaction.id,
        transaction.value.toStringAsFixed(2),
        dateFormatter.format(transaction.date),
        transaction.title ?? '',
        transaction.notes ?? '',
        transaction.account.name,
        transaction.account.currencyId,
        if (transaction.isIncomeOrExpense)
          (transaction.category!.parentCategory != null
              ? transaction.category!.parentCategory!.name
              : transaction.category!.name),
        if (transaction.isTransfer) 'TRANSFER',
        (transaction.category?.parentCategory != null
            ? transaction.category?.name
            : ''),
        transaction.status?.name == 'reconciled' ? 'Considerada' : 'Desconsiderada',
        transaction.manipulated == true ? 'Sim' : 'Não',
      ];

      csvData += toAdd.join(separator);

      csvData += '\n';

      if (transaction.isTransfer) {
        final toAdd = [
          transaction.id,
          (transaction.valueInDestiny ?? transaction.value).toStringAsFixed(2),
          dateFormatter.format(transaction.date),
          transaction.title ?? '',
          transaction.notes ?? '',
          transaction.receivingAccount!.name,
          transaction.receivingAccount!.currencyId,
          'TRANSFER',
          '',
          transaction.status?.name == 'reconciled' ? 'Considerada' : 'Desconsiderada',
          transaction.manipulated.toString(),
        ];

        csvData += toAdd.join(separator);

        csvData += '\n';
      }
    }

    final file = File(filePath);
    await file.writeAsString(csvData);
    
    await Share.shareXFiles([XFile(filePath)], text: 'Veja o anexo com suas transações');
    
    return fileName;
  }

  Future<bool> importDatabase() async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: Platform.isWindows ? FileType.custom : FileType.any,
        allowedExtensions: Platform.isWindows ? ['db'] : null,
        allowMultiple: false,
      );
    } catch (e) {
      throw Exception(e.toString());
    }

    if (result != null) {
      File selectedFile = File(result.files.single.path!);

      // Delete the previous database
      String dbPath = await db.databasePath;

      final currentDBContent = await File(dbPath).readAsBytes();

      // Load the new database
      await File(dbPath)
          .writeAsBytes(await selectedFile.readAsBytes(), mode: FileMode.write);

      try {
        final dbVersion = int.parse((await AppDataService.instance
            .getAppDataItem(AppDataKey.dbVersion)
            .first)!);

        if (dbVersion < db.schemaVersion) {
          await db.migrateDB(dbVersion, db.schemaVersion);
        }

        db.markTablesUpdated(db.allTables);
      } catch (e) {
        // Reset the DB as it was
        await File(dbPath).writeAsBytes(currentDBContent, mode: FileMode.write);
        db.markTablesUpdated(db.allTables);

        print('Error\n: $e');

        throw Exception('The database is invalid or could not be readed');
      }

      return true;
    }

    return false;
  }

  Future<File?> readFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      return File(result.files.single.path!);
    }

    return null;
  }

  Future<List<List<dynamic>>> processCsv(String csvData) async {
    return const CsvToListConverter().convert(csvData, eol: '\n');
  }
}
