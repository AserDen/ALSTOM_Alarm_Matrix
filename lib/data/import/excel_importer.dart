import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';

import '../db.dart';
import 'column_map.dart';

class ExcelImporter {
  final AppDb db;
  ExcelImporter(this.db);

  Future<int> importBytes(Uint8List bytes) async {
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables['Sheet1_clean'] ?? excel.tables['1'];
    if (sheet == null) {
      throw Exception('Не найден лист Sheet1_clean или 1');
    }
    if (sheet.rows.isEmpty) return 0;

    final headers = sheet.rows.first.map((c) => _cellToString(c)).toList();
    final headerNorm = headers.map(ColumnMap.norm).toList();

    int idxByAliases(String key) {
      final aliases = ColumnMap.headerAliases[key] ?? const [];
      for (final a in aliases) {
        final i = headerNorm.indexOf(ColumnMap.norm(a));
        if (i >= 0) return i;
      }
      return -1;
    }

    final iFault = idxByAliases(ColumnMap.faultNumber);
    final iFail = idxByAliases(ColumnMap.failure);

    if (iFault < 0 || iFail < 0) {
      throw Exception('Не найдены обязательные колонки Fault number / FAILURE');
    }

    final iAddr = idxByAliases(ColumnMap.remoteAddress);
    final iSubset = idxByAliases(ColumnMap.subsets);
    final iAlarmItem = idxByAliases(ColumnMap.alarmItem);
    final iDesignation = idxByAliases(ColumnMap.designation);
    final iGroup = idxByAliases(ColumnMap.dcsGroup);
    final iLogic = idxByAliases(ColumnMap.logic);
    final iCond = idxByAliases(ColumnMap.condition);
    final iTempo = idxByAliases(ColumnMap.tempo);

    int imported = 0;

    await db.transaction(() async {
      for (int r = 1; r < sheet.rows.length; r++) {
        final row = sheet.rows[r];
        if (row.isEmpty) continue;

        final faultNumber = int.tryParse(_get(row, iFault));
        if (faultNumber == null) continue;

        final failureText = _get(row, iFail).trim();
        if (failureText.isEmpty) continue;

        final remoteAddress = int.tryParse(_get(row, iAddr));
        final subset = _nullIfBlank(_get(row, iSubset));

        final alarmItem = _nullIfBlank(_get(row, iAlarmItem));
        final designation = _nullIfBlank(_get(row, iDesignation));
        final dcsGroup = _nullIfBlank(_get(row, iGroup));
        final logic = _nullIfBlank(_get(row, iLogic));
        final condition = _nullIfBlank(_get(row, iCond));
        final tempo = _nullIfBlank(_get(row, iTempo));

        final rawMap = <String, dynamic>{};
        for (int c = 0; c < headers.length; c++) {
          final key = headers[c].trim();
          if (key.isEmpty) continue;
          rawMap[key] = _get(row, c);
        }

        await db.into(db.faults).insertOnConflictUpdate(
              FaultsCompanion.insert(
                faultNumber: Value(faultNumber),
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
