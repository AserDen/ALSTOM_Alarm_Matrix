import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../faults_list/faults_list_vm.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Import Excel (.xlsx)'),
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
                    SnackBar(content: Text('Imported: $count rows')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import error: $e')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Tip: Prefer alarm_matrix_analysis.xlsx (Sheet1_clean) for stable headers.\n'
            'Fallback: sheet "1" is also supported.',
          ),
        ],
      ),
    );
  }
}
