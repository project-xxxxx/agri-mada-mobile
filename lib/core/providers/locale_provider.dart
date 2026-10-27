import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local_db/session_service.dart';

final initialLocaleProvider = Provider<Locale>((_) => const Locale('fr'));

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(ref.watch(initialLocaleProvider)),
);

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(super.initial);

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await SessionService.instance.saveLocaleCode(locale.languageCode);
  }

  Locale getLocale() => state;
}
