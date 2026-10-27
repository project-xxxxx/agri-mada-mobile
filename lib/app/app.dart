import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

import '../core/providers/locale_provider.dart';
import 'theme/app_theme.dart';
import 'router.dart';

/// Fournit les [MaterialLocalizations] françaises pour la locale malgache,
/// car [GlobalMaterialLocalizations] ne supporte pas 'mg'.
class _MgMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MgMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('fr'));

  @override
  bool shouldReload(_MgMaterialLocalizationsDelegate old) => false;
}

/// Fournit les [CupertinoLocalizations] françaises pour la locale malgache,
/// car [GlobalCupertinoLocalizations] ne supporte pas 'mg'.
class _MgCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _MgCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('fr'));

  @override
  bool shouldReload(_MgCupertinoLocalizationsDelegate old) => false;
}

class AgriMadaApp extends ConsumerWidget {
  const AgriMadaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'AgriMada',
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: const [
        Locale('fr'),
        Locale('mg'),
      ],
      // flutter_localizations ne supporte pas 'mg'. Quand la locale est 'mg',
      // AppLocalizations.delegate fournit les chaînes MG (coverage complète).
      // GlobalMaterialLocalizations ne trouvant pas 'mg', Flutter sélectionne
      // automatiquement 'fr' (présent dans supportedLocales) pour les widgets
      // Material système (boutons de dialog, sélecteurs de date, etc.).
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('fr');
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) return supported;
        }
        return const Locale('fr');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        _MgMaterialLocalizationsDelegate(),
        _MgCupertinoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
