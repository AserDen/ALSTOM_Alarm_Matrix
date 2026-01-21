import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../faults_list/faults_list_vm.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            l10n.dataSection,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.importExcel),
            onPressed: () async {
              final res = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['xlsx'],
                withData: true,
              );
              if (res == null || res.files.isEmpty) return;

              final bytes = res.files.first.bytes;
              if (bytes == null) return;

              try {
                final count = await ref.read(importerProvider).importBytes(bytes);
                ref.invalidate(subsetsListProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.importedRows(count))),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.importError(e.toString()))),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),
          Text(l10n.importTip),
        ],
      ),
    );
  }
}
