import 'package:drift/drift.dart';

import '../db.dart';

class FaultsQuery {
  final String search;
  final String? subset;
  final bool onlyWithAlarmItem;

  const FaultsQuery({
    this.search = '',
    this.subset,
    this.onlyWithAlarmItem = false,
  });
}

class FaultsRepo {
  final AppDb db;
  FaultsRepo(this.db);

  Stream<List<Fault>> watchFaults(FaultsQuery q) {
    final tbl = db.faults;
    final query = db.select(tbl);

    if (q.subset != null && q.subset!.trim().isNotEmpty) {
      query.where((t) => t.subset.equals(q.subset!.trim()));
    }

    if (q.onlyWithAlarmItem) {
      query.where(
        (t) => t.alarmItem.isNotNull() & t.alarmItem.trim().isNotValue(''),
      );
    }

    final s = q.search.trim();
    if (s.isNotEmpty) {
      final asInt = int.tryParse(s);
      if (asInt != null) {
        query.where((t) => t.faultNumber.equals(asInt));
      } else {
        final like = '%${s.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
        query.where(
          (t) => t.failureText.like(like) |
              t.alarmItem.like(like) |
              t.designation.like(like) |
              t.dcsGroup.like(like),
        );
      }
    }

    query.orderBy([(t) => OrderingTerm(expression: t.faultNumber)]);
    return query.watch();
  }

  Future<Fault?> getByFaultNumber(int faultNumber) {
    return (db.select(db.faults)
          ..where((t) => t.faultNumber.equals(faultNumber)))
        .getSingleOrNull();
  }

  Future<List<String>> listDistinctSubsets() async {
    final rows = await db.customSelect(
      'SELECT DISTINCT subset FROM faults '
      'WHERE subset IS NOT NULL AND TRIM(subset) <> "" '
      'ORDER BY subset',
      readsFrom: {db.faults},
    ).get();
    return rows.map((r) => r.data['subset'] as String).toList();
  }
}
