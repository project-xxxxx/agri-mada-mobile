import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/features/auth/domain/usecases/register_usecase.dart';
import 'package:agri_mada/features/auth/presentation/screens/register_screen.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RegisterScreen', () {
    testWidgets('affiche les champs d inscription', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('fr'), Locale('mg')],
          ),
        ),
      );

      // Assert
      expect(find.text('Nom'), findsOneWidget);
      expect(find.text('Prénom'), findsOneWidget);
      expect(find.text('Région'), findsOneWidget);
      expect(find.text('Téléphone'), findsOneWidget);
    });
  });
}
