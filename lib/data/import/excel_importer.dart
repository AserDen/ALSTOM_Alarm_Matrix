import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:drift/drift.dart';
import '../db.dart';

class ExcelImporter {
  final AppDb db;
  ExcelImporter(this.db);

  Future<int> importBytes(Uint8List bytes) async {
    final excel = Excel.decodeBytes(bytes);

    Sheet? sheet = excel.tables['Sheet1_clean'] ?? excel.tables['1'];
    if (sheet == null) {
      throw Exception('Не найден лист Sheet1_clean или 1');
    }

    // Первая строка — заголовки
    final headerRow = sheet.rows.first;
    final headers = headerRow.map((c) => _cellToString(c)).toList();

    // Индексы нужных колонок (по названиям)
    int idx(String name) => headers.indexWhere(
      (h) => h.trim().toLowerCase() == name.trim().toLowerCase(),
    );

    final iFault = idx('Fault number                                  ( display on local panel )');
    final iAddr  = idx('Address Remote                              (OCTAL)');
    final iSubset= idx('Subsets');
    final iFail  = idx('FAILURE:');

    final iAlarmItem = idx('ALARM ITEM:');
    final iDesignation = idx('DESIGNATION:');
    final iGroup = idx('DCS GROUP:');
    final iLogic = idx('LOGIC:');
    final iCond = idx('CONDITION:');
    final iTempo = idx('TEMPO:');

    if (iFault < 0 || iFail < 0) {
      throw Exception('Не найдены обязательные колонки Fault number / FAILURE:');
    }

    int imported = 0;

    await db.transaction(() async {
      // пропускаем заголовок
      for (int r = 1; r < sheet.rows.length; r++) {
        final row = sheet.rows[r];
        if (row.isEmpty) continue;

        final faultStr = _get(row, iFault);
        final faultNumber = int.tryParse(faultStr);
        if (faultNumber == null) continue;

        final failureText = _get(row, iFail);
        if (failureText.trim().isEmpty) continue;

        final remoteAddress = int.tryParse(_get(row, iAddr));
        final subset = _nullIfBlank(_get(row, iSubset));

        final alarmItem = _nullIfBlank(_get(row, iAlarmItem));
        final designation = _nullIfBlank(_get(row, iDesignation));
        final dcsGroup = _nullIfBlank(_get(row, iGroup));
        final logic = _nullIfBlank(_get(row, iLogic));
        final condition = _nullIfBlank(_get(row, iCond));
        final tempo = _nullIfBlank(_get(row, iTempo));

        // rawJson = все колонки как key-value
        final rawMap = <String, dynamic>{};
        for (int c = 0; c < headers.length; c++) {
          final key = headers[c].trim();
          if (key.isEmpty) continue;
          rawMap[key] = _get(row, c);
        }

        await db.into(db.faults).insertOnConflictUpdate(
          FaultsCompanion.insert(
            faultNumber: faultNumber,
            remoteAddressOctal: Value(remoteAddress),
            subset: Value(subset),
            failureText: failureText,
            alarmItem: Value(alarmItem),
            designation: Value(designation),
            dcsGroup: Value(dcsGroup),
            logic: Value(logic),
            condition: Value(condition),
            tempo: Value(tempo),
            rawJson: jsonEncode(rawMap),
          ),
        );

        imported++;
      }
    });

    return imported;
  }

  String _get(List<Data?> row, int index) {
    if (index < 0 || index >= row.length) return '';
    return _cellToString(row[index]);
  }

  String _cellToString(Data? cell) {
    final v = cell?.value;
    if (v == null) return '';
    return v.toString();
  }

  String? _nullIfBlank(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }
}
