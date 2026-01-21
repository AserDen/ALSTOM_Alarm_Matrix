import 'package:drift/drift.dart';

import '../db.dart';

class NotesRepo {
  final AppDb db;
  NotesRepo(this.db);

  Stream<List<Note>> watchNotes(int faultNumber) {
    final q = (db.select(db.notes)
          ..where((n) => n.faultNumber.equals(faultNumber)))
        ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);
    return q.watch();
  }

  Future<void> addNote({
    required int faultNumber,
    required String note,
    String? author,
  }) async {
    final text = note.trim();
    if (text.isEmpty) return;
    await db.into(db.notes).insert(
          NotesCompanion.insert(
            faultNumber: faultNumber,
            note: text,
            author: Value(author),
          ),
        );
  }

  Future<void> deleteNote(int id) async {
    await (db.delete(db.notes)..where((n) => n.id.equals(id))).go();
  }
}
