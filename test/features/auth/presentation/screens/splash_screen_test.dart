import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_mada/features/auth/presentation/providers/session_provider.dart';
import 'package:agri_mada/features/auth/presentation/screens/splash_screen.dart';
import 'package:agri_mada/app/theme/app_colors.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

void main() {
  testWidgets('Splash shows brand title and uses primary background', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Évite le stockage sécurisé et le moteur TFLite réels pendant le test.
          appBootstrapProvider.overrideWith(
            (ref) async => const AppBootstrapSnapshot(
              isLoggedIn: false,
              isOnboardingDone: true,
              profile: <String, String?>{},
              isAiReady: true,
            ),
          ),
        ],
        child: const MaterialApp(
          home: SplashScreen(),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('fr')],
        ),
      ),
    );
    // L'écran anime en continu : pas de pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('AgriMada'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.primary);
  });
}
