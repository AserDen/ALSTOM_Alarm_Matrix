import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/faults_list/faults_list_page.dart';
import 'features/settings/settings_page.dart';

class AlarmMatrixApp extends ConsumerWidget {
  const AlarmMatrixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Alarm Matrix',
      theme: ThemeData(useMaterial3: true),
      routes: {
        '/': (_) => const FaultsListPage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}
