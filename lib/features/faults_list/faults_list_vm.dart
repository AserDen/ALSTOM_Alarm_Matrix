import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db.dart';
import '../../data/import/excel_importer.dart';
import '../../data/repositories/faults_repo.dart';

final dbProvider = Provider<AppDb>((ref) => AppDb());

final faultsRepoProvider = Provider<FaultsRepo>((ref) {
  return FaultsRepo(ref.watch(dbProvider));
});

final importerProvider = Provider<ExcelImporter>((ref) {
  return ExcelImporter(ref.watch(dbProvider));
});

final searchProvider = StateProvider<String>((ref) => '');
final subsetProvider = StateProvider<String?>((ref) => null);
final onlyWithAlarmProvider = StateProvider<bool>((ref) => false);

final subsetsListProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(faultsRepoProvider).listDistinctSubsets();
});

final faultsStreamProvider = StreamProvider<List<Fault>>((ref) {
  final repo = ref.watch(faultsRepoProvider);
  final q = FaultsQuery(
    search: ref.watch(searchProvider),
    subset: ref.watch(subsetProvider),
    onlyWithAlarmItem: ref.watch(onlyWithAlarmProvider),
  );
  return repo.watchFaults(q);
});
