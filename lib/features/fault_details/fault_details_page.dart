import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'fault_details_vm.dart';

class FaultDetailsPage extends ConsumerStatefulWidget {
  final int faultNumber;
  const FaultDetailsPage({super.key, required this.faultNumber});

  @override
  ConsumerState<FaultDetailsPage> createState() => _FaultDetailsPageState();
}

class _FaultDetailsPageState extends ConsumerState<FaultDetailsPage> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final faultAsync = ref.watch(faultProvider(widget.faultNumber));
    final notesAsync = ref.watch(notesStreamProvider(widget.faultNumber));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.faultTitle(widget.faultNumber)),
      ),
      body: faultAsync.when(
        data: (f) {
          if (f == null) return Center(child: Text(l10n.notFound));
          final raw = _tryDecodeJson(f.rawJson);

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _kv(l10n.subsetLabel, f.subset),
              _kv(l10n.remoteAddress, f.remoteAddressOctal?.toString()),
              const SizedBox(height: 8),
              Text(f.failureText, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Text(
                l10n.alarmSection,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              _kv(l10n.alarmItem, f.alarmItem),
              _kv(l10n.designation, f.designation),
              _kv(l10n.dcsGroup, f.dcsGroup),
              _kv(l10n.logic, f.logic),
              _kv(l10n.tempo, f.tempo),
              _kv(l10n.condition, f.condition),
              const SizedBox(height: 16),
              ExpansionTile(
                title: Text(l10n.otherFields),
                children: [
                  if (raw == null)
                    ListTile(title: Text(l10n.rawJsonInvalid)),
                  if (raw != null)
                    ...raw.entries
                        .where((e) => e.key.trim().isNotEmpty)
                        .map(
                          (e) => ListTile(
                            dense: true,
                            title: Text(e.key),
                            subtitle: Text((e.value ?? '').toString()),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.notes,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.addNoteHint,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final text = _noteCtrl.text.trim();
                  if (text.isEmpty) return;
                  await ref.read(notesRepoProvider).addNote(
                        faultNumber: widget.faultNumber,
                        note: text,
                      );
                  _noteCtrl.clear();
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.addNoteButton),
              ),
              const SizedBox(height: 8),
              notesAsync.when(
                data: (notes) {
                  if (notes.isEmpty) return Text(l10n.noNotesYet);
                  return Column(
                    children: notes
                        .map(
                          (n) => Card(
                            child: ListTile(
                              title: Text(n.note),
                              subtitle: Text(n.createdAt.toIso8601String()),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    ref.read(notesRepoProvider).deleteNote(n.id),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(l10n.notesError(e.toString())),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.faultsError(e.toString()))),
      ),
    );
  }

  Widget _kv(String k, String? v) {
    final value = (v == null || v.trim().isEmpty) ? '—' : v.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Map<String, dynamic>? _tryDecodeJson(String s) {
    try {
      final x = jsonDecode(s);
      if (x is Map<String, dynamic>) return x;
    } catch (_) {}
    return null;
  }
}
