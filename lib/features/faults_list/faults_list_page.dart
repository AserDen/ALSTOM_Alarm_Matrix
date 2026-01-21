import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db.dart';
import '../fault_details/fault_details_page.dart';
import 'faults_list_vm.dart';

class FaultsListPage extends ConsumerWidget {
  const FaultsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faultsAsync = ref.watch(faultsStreamProvider);
    final subsetsAsync = ref.watch(subsetsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Matrix'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search: fault number / text / alarm item / designation...',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(searchProvider.notifier).state = v,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: subsetsAsync.when(
                    data: (items) {
                      final subset = ref.watch(subsetProvider);
                      return DropdownButtonFormField<String?>(
                        value: (subset == null || subset.isEmpty) ? null : subset,
                        decoration: const InputDecoration(
                          labelText: 'Subset',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All'),
                          ),
                          ...items.map(
                            (s) => DropdownMenuItem<String?>(value: s, child: Text(s)),
                          ),
                        ],
                        onChanged: (v) =>
                            ref.read(subsetProvider.notifier).state = v,
                      );
                    },
                    loading: () => const SizedBox(
                      height: 56,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Subset load error: $e'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Only with ALARM ITEM'),
                    value: ref.watch(onlyWithAlarmProvider),
                    onChanged: (v) =>
                        ref.read(onlyWithAlarmProvider.notifier).state = v,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: faultsAsync.when(
              data: (items) => _FaultList(items: items),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaultList extends StatelessWidget {
  final List<Fault> items;
  const _FaultList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No records. Import Excel in Settings.'));
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final f = items[i];
        final subtitle = f.failureText.length > 90
            ? '${f.failureText.substring(0, 90)}…'
            : f.failureText;
        return ListTile(
          title: Text('#${f.faultNumber}  ${f.subset ?? ''}'.trim()),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FaultDetailsPage(faultNumber: f.faultNumber),
            ),
          ),
        );
      },
    );
  }
}
