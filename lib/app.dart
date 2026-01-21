import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'features/faults_list/faults_list_page.dart';
import 'features/settings/settings_page.dart';

class AlarmMatrixApp extends ConsumerWidget {
  const AlarmMatrixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(useMaterial3: true),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('sr'),
        Locale('it'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('en');
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en');
      },
      routes: {
        '/': (_) => const FaultsListPage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}
