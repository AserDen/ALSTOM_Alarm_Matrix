import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db.dart';
import '../../data/repositories/notes_repo.dart';
import '../faults_list/faults_list_vm.dart';

final notesRepoProvider = Provider<NotesRepo>((ref) {
  return NotesRepo(ref.watch(dbProvider));
});

final faultProvider = FutureProvider.family<Fault?, int>((ref, faultNumber) {
  return ref.watch(faultsRepoProvider).getByFaultNumber(faultNumber);
});

final notesStreamProvider = StreamProvider.family<List<Note>, int>(
  (ref, faultNumber) {
    return ref.watch(notesRepoProvider).watchNotes(faultNumber);
  },
);