import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:agri_mada/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_mada/features/auth/presentation/screens/reset_password_screen.dart';

class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ResetPasswordScreen', () {
    late MockForgotPasswordUseCase mockForgotPasswordUseCase;

    setUp(() {
      mockForgotPasswordUseCase = MockForgotPasswordUseCase();
      when(() => mockForgotPasswordUseCase.call(tel: any(named: 'tel')))
          .thenAnswer((_) async => const Right<Failure, Unit>(unit));
    });

    testWidgets('affiche le formulaire de telephone', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            forgotPasswordUseCaseProvider
                .overrideWithValue(mockForgotPasswordUseCase),
          ],
          child: const MaterialApp(home: ResetPasswordScreen()),
        ),
      );

      // Assert
      expect(find.text('Téléphone'), findsOneWidget);
      expect(find.text('Envoyer'), findsOneWidget);
    });

    testWidgets('affiche une confirmation quand on envoie le formulaire', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            forgotPasswordUseCaseProvider
                .overrideWithValue(mockForgotPasswordUseCase),
          ],
          child: const MaterialApp(
            home: ResetPasswordScreen(),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('fr')],
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '0341234567');

      // Act
      await tester.tap(find.text('Envoyer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Assert
      expect(
        find.text(
          'Si ce numero est associe a un compte, des instructions seront envoyees.',
        ),
        findsOneWidget,
      );
    });
  });
}
